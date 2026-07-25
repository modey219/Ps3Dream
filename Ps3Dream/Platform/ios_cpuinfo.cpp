// Ps3Dream iOS - CPU Info (replaces Android cpuinfo.cpp)
// Uses sysctlbyname on iOS instead of /proc/cpuinfo

#include <stdio.h>
#include <string.h>
#include <string>
#include <vector>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <mach/mach.h>
#include <mach/machine.h>

struct core_info_t {
    std::string name;
    std::string isa;
    std::vector<std::string> features;
};

std::string cpu_get_simple_info(const std::vector<core_info_t>& cores) {
    char brand[256] = {};
    size_t size = sizeof(brand);
    sysctlbyname("machdep.cpu.brand_string", brand, &size, NULL, 0);
    return std::string(brand);
}

std::vector<core_info_t> cpu_get_core_info() {
    std::vector<core_info_t> cores;

    char brand[256] = {};
    size_t size = sizeof(brand);
    sysctlbyname("machdep.cpu.brand_string", brand, &size, NULL, 0);

    int core_count = 0;
    size = sizeof(core_count);
    sysctlbyname("hw.ncpu", &core_count, &size, NULL, 0);

    core_info_t info;
    info.name = std::string(brand);
    info.isa = "arm64";

    // Check for Apple Silicon features
    uint64_t cpu_family = 0;
    size = sizeof(cpu_family);
    sysctlbyname("hw.cpufamily", &cpu_family, &size, NULL, 0);

    uint64_t cpufeature = 0;
    size = sizeof(cpufeature);
    sysctlbyname("hw.optional.neon", &cpufeature, &size, NULL, 0);
    if (cpufeature) info.features.push_back("NEON");

    sysctlbyname("hw.optional.armv8_1_atomics", &cpufeature, &size, NULL, 0);
    if (cpufeature) info.features.push_back("Atomics");

    sysctlbyname("hw.optional.armv8_2_fphp", &cpufeature, &size, NULL, 0);
    if (cpufeature) info.features.push_back("FPHP");

    sysctlbyname("hw.optional.armv8_3_fphp", &cpufeature, &size, NULL, 0);
    if (cpufeature) info.features.push_back("FP16");

    sysctlbyname("hw.optional.amx_version", &cpufeature, &size, NULL, 0);
    if (cpufeature) {
        char amx_str[32];
        snprintf(amx_str, sizeof(amx_str), "AMX v%llu", cpufeature);
        info.features.push_back(amx_str);
    }

    info.features.push_back("ARM64");
    info.features.push_back("Apple Silicon");

    cores.push_back(info);
    return cores;
}
