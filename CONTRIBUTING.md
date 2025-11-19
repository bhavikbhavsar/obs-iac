# Contributing to Observability IaC

Thank you for your interest in contributing to this project! This document provides guidelines and instructions for contributing.

## 🚀 Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/obs-iac.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes thoroughly
6. Commit with clear messages
7. Push to your fork
8. Open a Pull Request

## 📝 Development Guidelines

### Code Style

- Follow Ansible best practices
- Use meaningful variable names
- Add comments for complex logic
- Keep tasks atomic and focused
- Use tags appropriately

### Directory Structure

```
obs-iac/
├── playbooks/          # Main playbooks
├── roles/              # Reusable roles
├── group_vars/         # Group-specific variables
├── inventory/          # Inventory files
└── README.md          # Documentation
```

### Naming Conventions

- **Variables**: Use lowercase with underscores (e.g., `cluster_name`)
- **Files**: Use lowercase with underscores (e.g., `deploy_cluster.yml`)
- **Roles**: Use lowercase with underscores (e.g., `rosa_cluster`)
- **Tags**: Use lowercase with hyphens (e.g., `aws-rosa`)

## 🧪 Testing

Before submitting a PR, ensure:

1. **Syntax Check**:
   ```bash
   ansible-playbook --syntax-check playbooks/your_playbook.yml
   ```

2. **Dry Run**:
   ```bash
   ansible-playbook --check -i inventory/aws playbooks/deploy_rosa.yml
   ```

3. **Linting**:
   ```bash
   ansible-lint playbooks/*.yml
   ```

4. **Full Test**: Test in a development environment

## 🔍 Pull Request Process

1. **Update Documentation**: Ensure README.md reflects your changes
2. **Test Thoroughly**: Test in dev environment
3. **Clear Description**: Explain what and why
4. **Link Issues**: Reference related issues
5. **Stay Focused**: One feature per PR

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
Describe testing performed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests added/updated
- [ ] All tests pass
```

## 🐛 Reporting Bugs

Use GitHub Issues with:
- Clear title
- Detailed description
- Steps to reproduce
- Expected vs actual behavior
- Environment details
- Relevant logs

## 💡 Feature Requests

For new features:
- Describe the feature
- Explain the use case
- Provide examples
- Discuss alternatives considered

## 📚 Documentation

Good documentation includes:
- Clear explanations
- Code examples
- Common use cases
- Troubleshooting tips

## 🔒 Security

Report security issues privately to the maintainers, not through public issues.

## ✅ Commit Messages

Follow conventional commits:

```
type(scope): subject

body (optional)

footer (optional)
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Testing
- `chore`: Maintenance

Examples:
```
feat(rosa): add support for private subnets
fix(aks): resolve credential timeout issue
docs(readme): update prerequisites section
```

## 🤝 Code Review

Reviewers should check:
- Code quality and style
- Test coverage
- Documentation completeness
- Security implications
- Performance impact

## 📞 Questions?

- Open a GitHub Discussion
- Join our community chat
- Email the maintainers

Thank you for contributing! 🎉

