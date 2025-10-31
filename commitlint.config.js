module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    // Disable body-max-line-length to allow generated release commits with URLs
    // This allows standard-version and semantic-release commits to pass validation
    'body-max-line-length': [0, 'always', Infinity],
  },
};
