#!/usr/bin/env node
const { execSync } = require("child_process");
clear
execSync("bash install.sh", { stdio: "inherit" });