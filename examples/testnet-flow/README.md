# Testnet 机密资产流程（与 `aptos-ts-sdk` TS 示例对齐）

本仓库的 Go / Python 绑定只提供**链下密码学**（离散对、Bulletproof 等），**不包含**构建/签名机密资产链上交易的能力。  
因此这里的 **Go / Python / Shell 入口** 与官方 TS 示例 **`aptos-ts-sdk/examples/bun-confidential-testnet/confidential-testnet.ts`** 使用**同一套环境变量**，并委托在同一台机器上已构建好的 TS 示例完成整条 Testnet 流程（注册 → 充值 → 归一化/滚存 → 解密打印 → 提现）。

## 前置条件

1. 克隆并构建 [`aptos-labs/aptos-ts-sdk`](https://github.com/aptos-labs/aptos-ts-sdk)（需 `pnpm build` 根包与 `confidential-asset` 子包），并在 `examples/bun-confidential-testnet` 执行过 `pnpm install`。
2. 本机已安装 **Node 22+**、**pnpm**，且 `pnpm exec tsx` 可用（Bun 可选，此处启动器固定使用 `pnpm exec tsx` 与 TS README 一致）。
3. 默认认为 `aptos-ts-sdk` 与本仓库 **同级目录**（见下方 `APTOS_TS_SDK_ROOT`）。若你的路径不同，请设置该环境变量。

## 环境变量（与 TS 示例一致）

| 变量 | 说明 |
|------|------|
| `APTOS_TS_SDK_ROOT` | **可选**。`aptos-ts-sdk` 仓库根目录的绝对路径。未设置时，启动器假定 SDK 在 `../../aptos-ts-sdk`（相对 **本 bindings 仓库根**）。 |
| `APTOS_NETWORK` | 可选。默认 `testnet`（与 TS 中 `NetworkToNetworkName` 小写键一致）。 |
| `APTOS_PRIVATE_KEY` | **推荐**。Ed25519 私钥（`ed25519-priv-0x...` 或 SDK 支持的 hex）。优先级最高。 |
| `FIXED_ED25519_PRIVATE_KEY` | 可选。与 TS 示例中环境变量同名；未设置 `APTOS_PRIVATE_KEY` 时使用。 |
| `APTOS_TWISTED_ED25519_PRIVATE_KEY` | 可选。TwistedEd25519 解密钥；不设则由 Ed25519 账户对固定消息派生（与 TS 一致）。 |

> 若既未设置 `APTOS_PRIVATE_KEY` / `FIXED_ED25519_PRIVATE_KEY`（环境或 TS 文件内常量），TS 脚本会报错退出。

复制示例 env 文件：

```bash
cp env.example .env
# 编辑 .env 后：
set -a && source .env && set +a   # bash
```

## 运行方式（三选一）

### Shell

```bash
./run.sh
```

### Go（仅启动器，不链接 CGO）

```bash
cd go && go run .
```

### Python

```bash
python3 python/run_flow.py
```

以上三种方式都会 `cd` 到 `$APTOS_TS_SDK_ROOT/examples/bun-confidential-testnet` 并执行：

`pnpm exec tsx confidential-testnet.ts`

环境变量会原样传入子进程。

## 仅验证本仓库 Go / Python 绑定（密码学）

链上流程以外的绑定自测仍使用原有目录：

- Go：`examples/go`
- Python：`bindings/python`（`maturin develop` + `pytest`）
