_cp = require "child_process"
_path = require "path"

option "-o", "--out [output]", "set output file path"
option "-e", "--env [BABEL_ENV]", "sets BABEL_ENV to the passed value"

task "build", "build the project", ({env, out}) ->
  process.env.BABEL_ENV = env
  _cp.execSync "#{_path.join __dirname, "node_modules/.bin/coffee"} -o #{out} -bct src/"
