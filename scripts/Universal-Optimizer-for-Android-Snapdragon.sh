#!/system/bin/sh

# Run
echo "Universal Optimizer is running"

# Light scheduler tweaks
echo "Enable light scheduler tweaks"
if [ -f /proc/sys/kernel/sched_autogroup_enabled ]; then
    su -c "echo 0 > /proc/sys/kernel/sched_autogroup_enabled"
fi

# Reduce CPU latency
echo "Reduce CPU latency"
su -c "echo 1 > /proc/sys/kernel/sched_child_runs_first"

# Boosting performance while charging
echo "Boosting performance while charging"
su -c "echo 1 > /sys/class/power_supply/battery/charging_enabled"
su -c "echo 0 > /sys/class/power_supply/battery/input_suspend"

# Optimize I/O scheduler and set custom I/O scheduler
echo "Checking available I/O schedulers..."
AVAILABLE=$(su -c "cat /sys/block/mmcblk0/queue/scheduler")
sleep 3
echo "Available I/O schedulers: $AVAILABLE"
AVAILABLE_CLEAN=$(echo "$AVAILABLE" | sed 's/\[//g;s/\]//g')

if [ -z "$1" ]; then
    read -p "Enter your desired scheduler (or 'skip'): " USER_CHOICE
else
    USER_CHOICE="$1"
fi

if [ "$USER_CHOICE" = "skip" ]; then
    echo "Skipping scheduler change."
else
    echo "$AVAILABLE_CLEAN" | grep -qw "$USER_CHOICE"
    if [ $? -eq 0 ]; then
        SELECTED_SCHEDULER="$USER_CHOICE"
    else
        echo "Error: Scheduler '$USER_CHOICE' is not available!"
        echo "Available schedulers: $AVAILABLE_CLEAN"
        exit 1
    fi
    echo "Applying scheduler: $SELECTED_SCHEDULER"
    su -c "echo '$SELECTED_SCHEDULER' > /sys/block/mmcblk0/queue/scheduler"
    su -c "echo '512' > /sys/block/mmcblk0/queue/read_ahead_kb"
    NEW_SCHEDULER=$(su -c "cat /sys/block/mmcblk0/queue/scheduler")
    echo "Current scheduler: $NEW_SCHEDULER"
fi

# Clear system cache
echo "Clearing system cache..."
su -c "sync; echo 3 > /proc/sys/vm/drop_caches"
su -c "echo 1 > /proc/sys/vm/compact_memory"

# Set cache ratio
echo "Setting cache ratio..."
su -c "echo 80 > /proc/sys/vm/dirty_ratio"
su -c "echo 40 > /proc/sys/vm/dirty_background_ratio"

# Cleaning up junk files
echo "Cleaning up junk files..."
su -c "rm -rf /data/system/dropbox/*"
su -c "rm -rf /data/system/usagestats/*"
su -c "rm -rf /data/anr/*"
su -c "rm -rf /data/tombstones/*"
su -c "rm -rf /data/cache/*"

# Optimizing Dalvik VM cache
echo "Optimizing Dalvik VM cache..."
su -c "setprop dalvik.vm.heapstartsize 8m"
su -c "setprop dalvik.vm.heapgrowthlimit 192m"
su -c "setprop dalvik.vm.heapsize 256m"
su -c "setprop dalvik.vm.heapminfree 2m"
su -c "setprop dalvik.vm.heapmaxfree 8m"

# Disable GMS background usage
echo "Disabling GMS background usage"
if command -v cmd >/dev/null 2>&1; then
    su -c "dumpsys deviceidle whitelist -com.google.android.gms"
    su -c "dumpsys deviceidle whitelist -com.google.android.googlequicksearchbox"
    su -c "dumpsys deviceidle whitelist -com.google.android.ims"
else
    echo "cmd command not available, skipping GMS background usage disable..."
fi

# Kill GMS apps
echo "Kill GMS apps"
su -c "pkill -f com.google.android.gms"
su -c "pkill -f com.google.android.googlequicksearchbox"
su -c "pkill -f com.google.android.ims"
su -c "pkill -f com.google.android.apps.messaging"
su -c "pkill -f com.google.android.as"

# Close background apps
echo "Closing background apps..."
su -c "sync; echo 1 > /proc/sys/vm/drop_caches"

# Whitelist apps
WHITELIST="init zygote zygote64 system_server servicemanager hwservicemanager vndservicemanager surfaceflinger com.android.systemui com.android.settings android.hardware.keymaster@4.0-service-qti android.hardware.bluetooth@1.0-service-qti android.hardware.camera.provider@2.4-service android.hardware.gnss@2.0-service-qti android.hardware.graphics.allocator@2.0-service android.hardware.graphics.composer@2.1-service android.hardware.health@2.1-service android.hardware.sensors@1.0-service android.hardware.usb@1.0-service android.hardware.wifi@1.0-service com.xiaomi.parts vendor.display.color@1.0-service vendor.qti.hardware.soter@1.0-service vendor.qti.hardware.vibrator.service vendor.qti.hardware.tui_comm@1.0-service-qti"

is_whitelisted() {
    for app in $WHITELIST; do
        if echo "$1" | grep -q "$app"; then
            return 0
        fi
    done
    return 1
}

# Force kill apps (set oom_score_adj)
echo "Force killing apps by setting oom_score_adj"
if command -v ps >/dev/null 2>&1; then
    ps -A -o pid,cmd | grep -E "u0_a" | while read -r app_pid app_name; do
        [ -z "$app_pid" ] && continue
        [ ! -d "/proc/$app_pid" ] && continue

        if is_whitelisted "$app_name"; then
            echo "Skipping whitelisted app: $app_name (PID: $app_pid)"
            continue
        fi

        su -c "echo 1000 > /proc/$app_pid/oom_score_adj" 2>/dev/null || echo "Warning: Failed to adjust oom_score_adj for $app_pid"
    done
fi

sleep 1

# --- Aggressive User App Cleanup ---
# This section aggressively closes user apps in the background as a fallback.

echo "Syncing file systems..."
su -c "sync"

echo "Freeing memory (drop caches)..."
su -c "echo 3 > /proc/sys/vm/drop_caches"

echo "Killing non-system user applications..."
if command -v ps >/dev/null 2>&1; then
    ps -A -o pid,cmd | grep -E "u0_a" | while read -r app_pid app_name; do
        [ -z "$app_pid" ] && continue
        [ ! -d "/proc/$app_pid" ] && continue

        if is_whitelisted "$app_name"; then
            echo "Skipping whitelisted: $app_name ($app_pid)"
            continue
        fi

        su -c "kill -9 $app_pid" 2>/dev/null || echo "Warning: Kill failed: $app_pid"
    done
fi

pids=$(jobs -p)
if [ -n "$pids" ]; then
    kill $pids
    echo "Stopped foreground jobs."
else
    echo "No foreground jobs running."
fi

pkill -u $(whoami) --ignore-case --signal SIGTERM -o $$
echo "Terminated user processes (gracefully)."

sleep 2

running_pids=$(su -c "lsof | grep /data/app | awk '{print \$2}' | sort -u")

if [ -z "$running_pids" ]; then
    echo "No user apps found running."
else
    for app_pid in $running_pids; do
        [ -z "$app_pid" ] && continue
        [ ! -d "/proc/$app_pid" ] && continue

        app_name=$(basename "$(cat /proc/$app_pid/cmdline | tr -d '\0')")

        if is_whitelisted "$app_name"; then
            echo "Skipping whitelisted: $app_name"
            continue
        fi

        su -c "kill -9 $app_pid" 2>/dev/null || echo "Warning: Force kill failed: $app_pid ($app_name)"
    done
fi

# End
echo "Optimization is complete!"
