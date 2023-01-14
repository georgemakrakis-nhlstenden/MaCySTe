#!/usr/bin/env python3
import re

from pathlib import Path

alloc_file_name, cidr, allocation_name = re.split(r'\s', input(''), 3)

ALLOC_FILE = Path(alloc_file_name)
ALLOC_FILE.touch(exist_ok = True)

allocation_re = re.compile(r'^([^#]*[^\s]+)[\s]*=[\s]*([^\s]+).*')

allocations = {}
for line in ALLOC_FILE.read_text().splitlines(False):
  m = allocation_re.match(line)
  if m is None: continue
  name = m.group(1)
  ip = m.group(2)
  allocations[name] = ip

if allocation_name not in allocations:
  # Import libraries
  import ipaddress, sys
  from datetime import datetime
  # Parse net CIDR
  net = ipaddress.ip_network(cidr)
  # Get allocated IPs of network
  allocated_ips = set()
  for ip_str in allocations.values():
    ip = ipaddress.ip_address(ip_str)
    if ip in net:
      allocated_ips.add(ip)
  # Allocate first host
  allocated_ips.add(next(net.hosts()))
  # Find first free IP
  free_ip = None
  for ip in net.hosts():
    if ip in allocated_ips: continue
    free_ip = ip
    break
  if free_ip is None: raise RuntimeError(f'No IPs available in net {net}')
  # Allocate it
  allocations[allocation_name] = free_ip.exploded
  # Rewrite file
  with open(ALLOC_FILE, 'w') as file:
    file.write(f'# Autogenerated by {sys.argv[0]} at {datetime.now().isoformat()}\n')
    for name in sorted(allocations.keys()):
      ip = allocations[name]
      file.write(f'{name} = {ip}\n')

print(allocations[allocation_name], end = '')