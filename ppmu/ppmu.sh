#!/usr/bin/env bash
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)

show_usage() {
    echo "$1 <start|stop>"
    echo "calcuate ppmu bandwith"
}

if [[ $1 == "-h" || $1 == "--help" ]]; then
    show_usage
    exit 1
fi

rm -f /tmp/ppmu_fifo_*
sync

# get the latest sequence number in csv file
# algorithem: for example, there are 2 sequence numbers: 10 and 1234567
# 10 will be recognized as a valid sequence number, because its ip_index is increamental by 1 continously
############
# 10 0 xxxx
# 10 1 xxxx
# 10 2 xxxx
###########
# 1234567 won't be recognized as an valid sequence number, because its ip_index is random
###########
# 1234567  5  xxxx
# 1234567  20 xxxx
# 1234567  30 xxxx
###########
# we find the max sequence number inside all the valid sequence numnbers.
# the max sequence number should be the latest sequence number
get_latest_seq()
{
    awk -F ',' \
    'BEGIN {
        last_seq_no = -1
        same_sample = 0
        same_sample_ip_idx = -1
        getline
        getline
    }
    {
        if ($1 >= last_seq_no && same_sample == $1 && (same_sample_ip_idx + 1 ) == $2) {
            # this is a valid sample
            last_seq_no = $1
        }
        same_sample = $1
        same_sample_ip_idx = $2
    }
    END {
        print last_seq_no
    }' /var/log/*.csv
}

start_ppmu()
{
# enable log capture
echo 1 > /sys/kernel/debug/exynos-pd/dbgdev-pd-acc
echo 1 > /sys/kernel/debug/exynos-pd/dbgdev-pd-taa0
echo 1 > /sys/kernel/debug/exynos-pd/dbgdev-pd-taa1
echo 1 > /sys/kernel/debug/exynos-pd/dbgdev-pd-ispb0
echo 1 > /sys/kernel/debug/exynos-pd/dbgdev-pd-ispb1
echo 1 > /sys/kernel/debug/exynos-pd/dbgdev-pd-npu00
echo 1 > /sys/kernel/debug/exynos-pd/dbgdev-pd-npu01
echo 1 > /sys/kernel/debug/exynos-pd/dbgdev-pd-npu10
echo 1 > /sys/kernel/debug/exynos-pd/dbgdev-pd-npu11
# set capture period to 100 ms
echo 100 > /sys/devices/platform/exynos-bcmdbg/bcm_attr/period_ctrl

while true;do
    rm -f /var/log/*.csv
    sync
    # start capture
    echo 1 > /sys/devices/platform/exynos-bcmdbg/bcm_attr/run_ctrl
    sleep 1
    # stop capture
    echo 0 > /sys/devices/platform/exynos-bcmdbg/bcm_attr/run_ctrl
    if ls /var/log/*.csv 2>&1 >/dev/null; then
        # 1)get the lastest reasonable sequnce number in csv file
        current_sequence=$(get_latest_seq)
        echo $current_sequence
        # 2)send current_sequence to awk script, to get cpu,gpu,dpu values
        ppmu_info=$(awk -F ',' -f "$SCRIPT_DIR"/ppmucalc.awk -v SEQUENCE=$current_sequence /var/log/*.csv)
        # 3)store into files, for htop to read
        echo "$ppmu_info" | grep cpu > /tmp/ppmu_fifo_cpu
        echo "$ppmu_info" | grep gpu > /tmp/ppmu_fifo_gpu
        echo "$ppmu_info" | grep dpu > /tmp/ppmu_fifo_dpu
        echo "$ppmu_info" | grep mfc > /tmp/ppmu_fifo_mfc
        echo "$ppmu_info" | grep isp > /tmp/ppmu_fifo_isp
        echo "$ppmu_info" | grep tot > /tmp/ppmu_fifo_tot
    fi
done
}

stop_ppmu()
{
# stop capture
echo 0 > /sys/devices/platform/exynos-bcmdbg/bcm_attr/run_ctrl
rm -f /tmp/ppmu_fifo_cpu
rm -f /tmp/ppmu_fifo_gpu
rm -f /tmp/ppmu_fifo_dpu
rm -f /tmp/ppmu_fifo_mfc
rm -f /tmp/ppmu_fifo_isp
rm -f /tmp/ppmu_fifo_tot
}

if [[ "$1" = "stop" ]];then
    stop_ppmu
elif [[ "$1" = "start" ]];then
    start_ppmu
fi
