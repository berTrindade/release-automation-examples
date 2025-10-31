module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    // Disable body-max-line-length to allow semantic-release generated commits
    // semantic-release includes URLs in commit bodies which can exceed 100 chars
    'body-max-line-length': [0, 'always', Infinity],
  },
};
