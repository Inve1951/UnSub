module.exports = {
  env: {
    minify: {
      presets: ["minify"],
      plugins: [
        "@babel/plugin-transform-classes",
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
