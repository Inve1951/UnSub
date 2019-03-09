module.exports = {
  env: {
    minify: {
      presets: ["minify"],
      plugins: [
        ["@babel/plugin-transform-modules-commonjs", {
          noInterop: true
        }]
      ],
      comments: false
    },
    module: {
      comments: false
    }
  }
}
