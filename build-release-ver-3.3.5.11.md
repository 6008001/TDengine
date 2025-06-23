- 安装 go、cmake、Visual Studio、gcc 环境


- 已安装 Go 1.17 及以上版本，并允许 CGO export CGO_ENABLED=1
    ```shell
    set CGO_ENABLED=1
    ```
    ```shell
    go env CGO_ENABLED
    ```


- build
    - 如果你想要编译 taosAdapter，需要添加 `-DBUILD_HTTP=false` 选项。
    - 如果你想要编译 taosKeeper，需要添加 `-DBUILD_KEEPER=true` 选项。
    - 打开使用 x64 Native Tools Command Prompt for VS 2022 窗口进行编译
    ```shell
    mkdir debug && cd debug
    ```
    ```shell
    cmake .. -G "NMake Makefiles" -DBUILD_HTTP=false -DBUILD_KEEPER=true
    ```
    ```shell
    nmake
    ```


- package (/release)
  ```shell
  cd packaging
  ```
  ```shell
  release.bat edge 3.3.5.11
  ```
  ```shell
  cd ../release
  ```

