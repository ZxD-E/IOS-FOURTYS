#include <iostream>
#include <vector>
#include <cstdlib>
#include <cstring>

class FourTysEngineMemoryPool {
private:
    size_t totalAllocatedBytes;
    std::vector<void*> allocatedBlocks;

public:
    FourTysEngineMemoryPool() : totalAllocatedBytes(0) {}

    void preallocateEngineCache(size_t megaBytes) {
        size_t bytesToAlloc = megaBytes * 1024 * 1024;
        void* ptr = malloc(bytesToAlloc);
        if (ptr) {
            memset(ptr, 0x00, bytesToAlloc);
            allocatedBlocks.push_back(ptr);
            totalAllocatedBytes += bytesToAlloc;
            std::cout << "[FourTys C++ Engine] Successfully allocated " << megaBytes << " MB Native Memory Pool." << std::endl;
        }
    }

    ~FourTysEngineMemoryPool() {
        for (void* block : allocatedBlocks) {
            if (block) free(block);
        }
        allocatedBlocks.clear();
    }
};

extern "C" void BootNativeEngineMemory() {
    static FourTysEngineMemoryPool pool;
    pool.preallocateEngineCache(35); // 35 MB Pre-allocated Native Core Memory
}