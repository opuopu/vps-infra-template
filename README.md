# VPS infra template (Ansible + Traefik)

নতুন প্রজেক্ট:

1. GitHub এ "Use this template" দিয়ে `<project>-infra` নামে private repo বানাও, তারপর WSL এ clone করো (`/mnt/c` তে না, `~` তে)।
2. `inventory.yml` বদলাও: নাম, IP, ইমেইল, ডোমেইন, port।
3. চালাও:

```bash
make init        # vault password + env ফাইল + git hook
nano env/backend.env   # আসল মান বসাও (website, admin এর জন্যও একই)
make encrypt
ssh-copy-id root@<IP>
make bootstrap   # একবার: deploy user, root login বন্ধ
make setup       # Docker, firewall, Traefik, SSL, env
```

env বদলাতে: `make edit-env APP=backend` → `make env`

ফাইল:

- `inventory.yml`: প্রজেক্টের একমাত্র কনফিগ
- `bootstrap.yml`: একবার, root হিসেবে চলে
- `site.yml`: যতবার খুশি চালানো যায়
- `templates/`: Traefik compose, headers/TLS, routes
- `env/`: ansible-vault দিয়ে encrypted env (git এ commit করা যায়)
- `examples/`: অ্যাপের docker-compose আর GitHub Actions এর নমুনা
