#!/bin/bash

# 字牌
mv ji_c.gif Etc_Center.png
mv ji_e.gif Etc_East.png
mv ji_hk.gif Etc_Hatsu.png
mv ji_n.gif Etc_North.png
mv ji_s.gif Etc_South.png
mv ji_w.gif Etc_West.png
mv ji_ht.gif Etc_White.png

# 萬子
for i in {1..9}; do
  mv ms${i}.gif Manzu${i}.png
done

# 筒子
for i in {1..9}; do
  mv ps${i}.gif Pinzu${i}.png
done

# 索子
for i in {1..9}; do
  mv ss${i}.gif Sowzu${i}.png
done