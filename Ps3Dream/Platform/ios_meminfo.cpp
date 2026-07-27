// Ps3Dream iOS - Memory Info (replaces Android meminfo.cpp)
// Uses mach API on iOS instead of /proc/self/maps

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <mach/mach.h>
#include <mach/mach_host.h>

uint64_t get_physical_memory_size() {
    int mib[2] = { CTL_HW, HW_MEMSIZE };
    uint64_t memsize = 0;
    size_t size = sizeof(memsize);
    sysctl(mib, 2, &memsize, &size, NULL, 0);
    return memsize;
}

uint64_t get_available_memory() {
    mach_port_t host = mach_host_self();
    vm_size_t page_size = 0;
    host_page_size(host, &page_size);

    vm_statistics64_data_t stat;
    mach_msg_type_number_t count = sizeof(stat) / sizeof(natural_t);
    if (host_statistics64(host, HOST_VM_INFO64, (host_info64_t)&stat, &count) == KERN_SUCCESS) {
        return (uint64_t)(stat.free_count + stat.inactive_count) * page_size;
    }
    return 0;
}
