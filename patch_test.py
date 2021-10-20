#!/usr/bin/env/python3
import sys
import re
from glob import glob

out_suffix=".PATCHED"

def parse_reg(reg_txt):
  return int(reg_txt[2:])  # strip leading '%s'

reg_map={}

def clean_patch(in_path, out_path):
  print("IN: {} // OUT: {}".format(in_path, out_path))
  in_func = False
  past_first_block = False
  past_sp_copy = False

  raw_lines = [raw_line for raw_line in open(in_path, 'r')]

  with open(out_path, 'w') as out:
    for raw_line in raw_lines:
      line=raw_line.strip()
      print(line)

      # skip autogen line
      if line.startswith("; NOTE: Assertions have been autogenerated"):
        continue

      # function body 
      if line.startswith("define"):
        in_func=True
        past_sp_copy=False
        past_first_block=False
        print("ENTER {}".format(line))
      elif line.startswith("}"):
        in_func=False
      
      # not a CHECK line
      if not line.startswith("; CHECK"):
        out.write(raw_line)
        continue

      # keep the function label check
      if line.startswith("; CHECK-LABEL:"):
        out.write(raw_line)
        continue

      # block -> rewrite into generic form
      if line.startswith("; CHECK-NEXT:  .LBB"):
        #  ; CHECK:       .LBB{{[0-9]+}}_2:

        # strip trailing comments
        idx_suffix = line.split('_')[-1]
        idx_suffix_parts = idx_suffix.split()
        idx_part = idx_suffix_parts[0]
        print("IDX: {}".format(idx_part))
        generic_bb_check="; CHECK:       .LBB{{[0-9]+}}_"
        bb_check=generic_bb_check + idx_part
        out.write(bb_check + "\n")
        past_first_block=True
        continue

      # keep checks between function prologue and epilogue
      if past_first_block and not past_sp_copy:
        out.write(raw_line)

      # is this the SP copy check?
      sp_copy_prefix="; CHECK-NEXT:    or %s11, 0, %s9"
      if line.startswith(sp_copy_prefix):
        past_sp_copy=True
      continue

     
      # OLD JUNK BELOW
    
      parts = l.split()
      semi = parts[0]
      if len(parts) < 2:
        continue
    
      directive = parts[1]
    
      # skip commments and blocks
      if parts[2].strip().startswith("#") or \
         parts[2].strip().startswith("."):
        continue
    
      out_reg_txt = parts[3]
      if out_reg_txt.startswith("%s"):
        # register allocated
        out_reg = parse_reg(out_reg_txt[:-1]) 
        print("DEFINE {}".format(out_reg))
        continue

for pattern in sys.argv[1:]:
  for in_file in glob(pattern):
    clean_patch(in_file, in_file)