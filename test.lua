local logger = require("core.helper.logger")
local exec = require("core.helper.exec")
-- local exec = require("core/helper/exec")
-- local installBasics = require("core/installer/install-basics")

-- exec.run("docker ps")

logger.info("hii")

local xx = exec.run("dd if=/dev/zero of=testfile bs=64K count=16384 conv=fdatasync,notrunc 2>&1 | grep -o '[0-9.]* [MG]B/s'")

logger.title(xx)