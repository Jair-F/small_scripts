## Antivirus transfer
<details>
  <summary>Linux</summary>

  - add_data:
    ```bash
    curl -sL https://raw.githubusercontent.com/Jair-F/small_scripts/refs/heads/master/transfer/add_data.sh | bash
    ```
  - remove_data:
    ```bash
    curl -sL https://raw.githubusercontent.com/Jair-F/small_scripts/refs/heads/master/transfer/remove_data.sh | bash
    ```

    <details>
    <summary>Linux with arguments</summary>

    - add_data:
        ```bash
        curl -sL https://raw.githubusercontent.com/Jair-F/small_scripts/refs/heads/master/transfer/add_data.sh | bash -s example_file.bin [4]
        ```
    </details>
</details>

<details>
  <summary>Windows</summary>

  - allow powershell script execution:
    ```powershell
    Set-ExecutionPolicy Unrestricted -Scope CurrentUser
    ```
  - add_data:
    ```powershell
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Jair-F/small_scripts/refs/heads/master/transfer/add_data.ps1" | Select-Object -ExpandProperty Content | Invoke-Expression
    ```
  - remove_data:
    ```powershell
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Jair-F/small_scripts/refs/heads/master/transfer/remove_data.ps1" | Select-Object -ExpandProperty Content | Invoke-Expression
    ```
</details>
