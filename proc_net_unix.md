In `/proc/net/unix`, **column 6 (`St`)** represents the kernel socket state from the `socket_state` enum in Linux (`include/uapi/linux/net.h`):

| Hex Value | Kernel Constant | Meaning for Unix Domain Sockets |
| :--- | :--- | :--- |
| **`01`** | `SS_UNCONNECTED` | **Unconnected / Listening:** A newly created socket or a bound server socket (`bind()` + `listen()`) waiting for incoming connections (this is the state your idle `ssh-agent` socket stays in). |
| **`02`** | `SS_CONNECTING` | **In progress:** A client socket actively in the middle of a `connect()` handshake. |
| **`03`** | `SS_CONNECTED` | **Connected:** An active, established connection between a client and server (e.g., `ssh-add` or `ssh` actively talking to `ssh-agent`). |
| **`04`** | `SS_DISCONNECTING` | **Closing:** A socket actively shutting down (`shutdown()` or `close()`). |
| **`00`** | `SS_FREE` | **Free:** Not allocated to any socket (rarely seen in `/proc/net/unix`). |

### How this applies to `ssh-agent`:
* **Listening socket (`01`):** `ssh-agent` creates a `SOCK_STREAM` Unix socket and calls `listen()`, which leaves the listener entry in state **`01` (`SS_UNCONNECTED`)** for its entire lifetime.
* **Active client session (`03`):** Whenever `ssh` or `ssh-add` connects to `GIT_SSH_AUTH_SOCK`, the kernel spawns a second entry with the same path in state **`03` (`SS_CONNECTED`)** until that command finishes.
* **Dead/stale socket:** When `ssh-agent` exits or is killed, **both** `01` and `03` entries disappear from `/proc/net/unix` immediately—leaving only the orphan socket file on disk. That is why checking `NF >= 8 && $NF == s && $6 == "01"` reliably distinguishes a live `ssh-agent` from a stale socket file.
