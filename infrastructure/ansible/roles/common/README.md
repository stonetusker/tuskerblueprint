# Common Role

## Purpose

Prepare Ubuntu hosts for platform installation.

## Responsibilities

- Update package cache
- Upgrade packages
- Install common utilities
- Configure locale
- Configure timezone
- Enable time synchronization

## Variables

| Variable | Default |
|----------|---------|
| common_timezone | UTC |
| common_locale | en_US.UTF-8 |
| common_packages | See defaults/main.yml |

## Dependencies

- community.general

## Example

```yaml
roles:
  - common
```
