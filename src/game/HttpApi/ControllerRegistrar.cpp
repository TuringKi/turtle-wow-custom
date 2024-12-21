#include "Config.hpp"
#include "TestController.hpp"
#include "TransferController.hpp"

namespace HttpApi
{
    void RegisterControllers()
    {
        new TestController();
        new TransferController(sConfig.GetStringDefault("HttpApi.TransferKey", "Gheor"));
    }
} // namespace HttpApi
