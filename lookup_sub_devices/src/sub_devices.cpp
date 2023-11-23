#include <level_zero/ze_api.h>
// #include <level_zero/zes_api.h>
#include <vector>
#include <iostream>
#include <ctime>


void printDeviceProperties(ze_device_handle_t device, std::string tab);
void printDriverProperties(ze_driver_handle_t driver);

bool checkErrors(ze_result_t res) {
    switch (res) {
        case ZE_RESULT_SUCCESS:
            return false;
        case ZE_RESULT_ERROR_UNINITIALIZED:
            std::cerr << "Uninitialized Sys API" << std::endl;
            break;
        case ZE_RESULT_ERROR_DEVICE_LOST:
            std::cerr << "Device Lost" << std::endl;
            break;
        case ZE_RESULT_ERROR_OUT_OF_HOST_MEMORY:
            std::cerr << "Out of Host Memory" << std::endl;
            break;
        case ZE_RESULT_ERROR_OUT_OF_DEVICE_MEMORY:
            std::cerr << "ZE_RESULT_ERROR_OUT_OF_DEVICE_MEMORY" << std::endl;
            break;
        case ZE_RESULT_ERROR_INVALID_ENUMERATION:
            std::cerr << "ZE_RESULT_ERROR_INVALID_ENUMERATION" << std::endl;
            break;
        default:
            std::cerr << "Unknown error: " << res << std::endl;
    }
    return true;
}

std::vector<ze_driver_handle_t> getAllDrivers() {
    
    std::vector<ze_driver_handle_t> allDrivers;
    uint32_t driverCount = 0;
    checkErrors(zeDriverGet(&driverCount, nullptr));

    allDrivers.resize(driverCount);
    checkErrors(zeDriverGet(&driverCount, allDrivers.data()));

    return allDrivers;
}

std::vector<ze_device_handle_t> getAllDevices(ze_driver_handle_t hDriver) {
    std::vector<ze_device_handle_t> allDevices;

    uint32_t deviceCount = 0;
    checkErrors(zeDeviceGet(hDriver, &deviceCount, nullptr));

    allDevices.resize(deviceCount);
    checkErrors(zeDeviceGet(hDriver, &deviceCount, allDevices.data()));

    return allDevices;
}

std::string typeToString(ze_device_type_t type) {
    switch (type)
    {
    case ZE_DEVICE_TYPE_GPU:
        return "GPU";
    case ZE_DEVICE_TYPE_CPU:
        return "CPU";
    case ZE_DEVICE_TYPE_FPGA:
        return "FPGA";
    case ZE_DEVICE_TYPE_MCA:
        return "MCA";
    case ZE_DEVICE_TYPE_VPU:
        return "VPU";
    case ZE_DEVICE_TYPE_FORCE_UINT32:
        return "FORCE_UINT32";
    default:
        return "Unknown";
    }
}

void printDeviceGeneralInfo(ze_device_handle_t device, std::string tab) {
    ze_device_properties_t props {};
    props.stype = ZE_STRUCTURE_TYPE_DEVICE_COMPUTE_PROPERTIES;

    if (checkErrors(zeDeviceGetProperties(device, &props))) {
        std::cout << tab << "Error getting device general properties" << std::endl;
        return;
    }

    std::cout << tab << "- Name: " << props.name << std::endl;
    std::cout << tab << "- Type: " << typeToString(props.type) << std::endl;
    std::cout << tab << "- Vendor ID: " << props.vendorId << std::endl;
    std::cout << tab << "- Device ID: " << props.deviceId << std::endl;
    std::cout << tab << "- Num Slices: " << props.numSlices << std::endl;
    std::cout << tab << "- Num Subslices per Slice: " << props.numSubslicesPerSlice << std::endl;
    std::cout << tab << "- Num EU per Subslice: " << props.numEUsPerSubslice << std::endl;
    std::cout << tab << "- Num Threads per EU: " << props.numThreadsPerEU << std::endl;
    std::cout << tab << "- Physical EU SIMD Width: " << props.physicalEUSimdWidth << std::endl;
    std::cout << tab << "- Command Queue Priority: " << props.maxCommandQueuePriority << std::endl;
    std::cout << tab << "- Max Hardware Contexts: " << props.maxHardwareContexts << std::endl;
    std::cout << tab << "- Max Memory Allocation Size: " << props.maxMemAllocSize << std::endl;
}

void printDeviceComputProperties(ze_device_handle_t device, std::string tab) {
    
    ze_device_compute_properties_t props {};
    props.stype = ZE_STRUCTURE_TYPE_DEVICE_COMPUTE_PROPERTIES;

    if (checkErrors(zeDeviceGetComputeProperties(device, &props))) {
        std::cout << tab << "Error getting device compute properties" << std::endl;
        return;
    }

    std::cout << tab << "- Max Group Count X: " << props.maxGroupCountX << std::endl;
    std::cout << tab << "- Max Group Count Y: " << props.maxGroupCountY << std::endl;
    std::cout << tab << "- Max Group Count Z: " << props.maxGroupCountZ << std::endl;

    std::cout << tab << "- Max Group Size X: " << props.maxGroupSizeX << std::endl;
    std::cout << tab << "- Max Group Size Y: " << props.maxGroupSizeY << std::endl;
    std::cout << tab << "- Max Group Size Z: " << props.maxGroupSizeZ << std::endl;

    std::cout << tab << "- Max Total Group Size: " << props.maxTotalGroupSize << std::endl;
    std::cout << tab << "- Max Shared Local Memory: " << props.maxSharedLocalMemory << std::endl;
    std::cout << tab << "- Num Sub Group Sizes: " << props.numSubGroupSizes << std::endl;
    std::cout << tab << "- Sub Group Sizes: ";
    for (int i = 0; i < props.numSubGroupSizes; ++i) {
        std::cout << props.subGroupSizes[i] << " ";
    }
    std::cout << std::endl;
}

void printDeviceMemoryProperty(ze_device_memory_properties_t props, std::string tab) {
    std::cout << tab << "- Name: " << props.name << std::endl;
    std::cout << tab << "- Total Size: " << props.totalSize << std::endl;
    std::cout << tab << "- Max Bus Width: " << props.maxBusWidth << std::endl;
    std::cout << tab << "- Max Clock Rate: " << props.maxClockRate << std::endl;
}

void printDeviceMemoryProperties(ze_device_handle_t device, std::string tab) {

    std::vector<ze_device_memory_properties_t> allProps;
    uint32_t props_count = 0;

    if (checkErrors(zeDeviceGetMemoryProperties(device, &props_count, nullptr))) {
        std::cout << tab << "Error getting the number of memory properties" << std::endl;
        return;
    }
    allProps.resize(props_count);
    if (checkErrors(zeDeviceGetMemoryProperties(device, &props_count, allProps.data()))) {
        std::cout << tab << "Error getting device memory properties" << std::endl;
        return;
    }

    for (int i = 0; i < props_count; ++i) {
        std::cout << tab << "\t[MEMORY #" << i << "]" << std::endl;
        printDeviceMemoryProperty(allProps[i], tab + "\t");
    }
}

void printSubDeviceProperties(ze_device_handle_t device, std::string tab) {
    uint32_t subDeviceCount = 0;
    std::vector<ze_device_handle_t> subDevices;

    if (checkErrors(zeDeviceGetSubDevices(device, &subDeviceCount, nullptr))) {
        std::cout << tab << "Error getting device sub-devices properties" << std::endl;
        return;
    }

    subDevices.resize(subDeviceCount);
    if (checkErrors(zeDeviceGetSubDevices(device, &subDeviceCount, subDevices.data()))) {
        std::cout << tab << "Error getting device sub-devices properties" << std::endl;
        return;
    }

    std::cout << tab << "- Sub-Device Count: " << subDeviceCount << std::endl;
    for (int i = 0; i < subDeviceCount; ++i) {
        std::cout << tab << "\t[SUB-DEVICE #" << i << "]" << std::endl;
        printDeviceProperties(subDevices[i], tab + "\t");
    }
}

void printDeviceProperties(ze_device_handle_t device, std::string tab) {
    ze_device_properties_t props {};
    props.stype = ZE_STRUCTURE_TYPE_DEVICE_PROPERTIES;

    
    std::cout << tab << "[General Info]" << std::endl;
    printDeviceGeneralInfo(device, tab);

    std::cout << tab << "[Compute Properties]" << std::endl;
    printDeviceComputProperties(device, tab);

    std::cout << tab << "[Memory Properties]" << std::endl;
    printDeviceMemoryProperties(device, tab);

    std::cout << tab << "[Sub-Devices Properties]" << std::endl;
    printSubDeviceProperties(device, tab);
}

void printDriverProperties(ze_driver_handle_t driver) {
    ze_driver_properties_t dProps {};
    dProps.stype = ZE_STRUCTURE_TYPE_DRIVER_PROPERTIES;

    if (!checkErrors(zeDriverGetProperties(driver, &dProps))) {
        std::cout << "Driver Version: " << dProps.driverVersion << std::endl;
    } else {
        std::cout << "Error getting driver properties" << std::endl;
    }
}

int main() {

    // Initialize the driver
    ze_result_t res = zeInit(0);
    if (checkErrors(res)) {
        exit(1);
    }

    // Discover all the driver instances
    auto all_drivers = getAllDrivers();

    int num_dev = 0;
    for (auto driver : all_drivers) {
        std::cout << "********** [DRIVER] **********" << std::endl;
        printDriverProperties(driver);
        auto allDevices = getAllDevices(driver);
        for (auto device : allDevices) {
            std::cout << "[DEVICE #" << num_dev++ << "]" << std::endl;
            printDeviceProperties(device, "\t");
        }
    }
}