// SPDX-License-Identifier: WTFPL

#ifndef APS3E_EMULATOR_APS3E_H
#define APS3E_EMULATOR_APS3E_H

#include "aps3e_rp3_impl.h"

extern void ppu_register_function_at(u32, u32, ppu_intrp_func_t);

namespace ae{
    extern std::string game_id;
    extern bool install_firmware(int fd);
    extern bool install_pkg(iso_fs& iso_fs, const std::string& path);
    extern bool install_pkg(const char* path);
    extern bool install_pkg(int pkg_fd);
    extern bool allow_eboot_decrypt(const fs::file& eboot_file);
    extern bool install_edat(const fs::file& edat_file);

    extern std::string get_gpu_info();
    extern std::string get_cpu_info();

    extern bool precompile_ppu_cache(const std::string& path,std::optional<int> fd);
    
    template <typename T> requires std::is_integral_v<T> std::vector<uint32_t> mem_search(const T value) {
        std::vector<uint32_t> result;
        for(uint32_t page_start=0x10000;page_start<0xf000'0000;page_start+=4096) {
            if(vm::check_addr(page_start)) {
                for(uint32_t offset=0;offset<4096;offset+=sizeof(T)) {
                    if(*vm::get_super_ptr<T>(page_start+offset)==value) {
                        result.push_back(page_start+offset);
                    }
                }
            }
        }
        return result;
    }



    template <typename T> requires std::is_integral_v<T> void mem_set_value(u32  addr,const T value)
    {
        if (Emu.IsStopped())
            return;

        if (!vm::check_addr<sizeof(T)>(addr))
        {
            return;
        }

        return cpu_thread::suspend_all(nullptr, {}, [&]
        {
            if (!vm::check_addr<sizeof(T)>(addr))
            {
                return;
            }

            *vm::get_super_ptr<T>(addr) = value;

            const bool exec_code_at_start = vm::check_addr(addr, vm::page_executable);
            const bool exec_code_at_end = [&]()
            {
                if constexpr (sizeof(T) == 1)
                {
                    return exec_code_at_start;
                }
                else
                {
                    return vm::check_addr(addr + sizeof(T) - 1, vm::page_executable);
                }
            }();

            if (exec_code_at_end || exec_code_at_start)
            {
                //extern void ppu_register_function_at(u32, u32, ppu_intrp_func_t);

                u32 size = sizeof(T);

                if (exec_code_at_end && exec_code_at_start)
                {
                    size = utils::align<u32>(addr + size, 4) - (addr & -4);
                    addr &= -4;
                }
                else if (exec_code_at_end)
                {
                    size -= utils::align<u32>(size - 4096 + (addr & 4095), 4);
                    addr = utils::align<u32>(addr, 4096);
                }
                else if (exec_code_at_start)
                {
                    size = utils::align<u32>(4096 - (addr & 4095), 4);
                    addr &= -4;
                }

                // Reinitialize executable code
                ppu_register_function_at(addr, size, nullptr);
            }

            return;
        });
    }

    template <typename T> requires std::is_integral_v<T> T mem_get_value(const u32 offset, bool& success)
    {
        if (Emu.IsStopped())
        {
            success = false;
            return 0;
        }

        return cpu_thread::suspend_all(nullptr, {}, [&]() -> T
        {
            if (!vm::check_addr<sizeof(T)>(offset))
            {
                success = false;
                return 0;
            }

            success = true;
            return *vm::get_super_ptr<T>(offset);
        });
    }

}
#endif //APS3E_EMULATOR_APS3E_H
