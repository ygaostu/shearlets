# Shearlet Systems for Light Field (LF) Reconstruction
Matlab scripts for generating tailored shearlet systems for light field reconstruction, which was originally proposed in 
```
@article{vagharshakyan2017light,
  title={Light field reconstruction using shearlet transform},
  author={Vagharshakyan, Suren and Bregovic, Robert and Gotchev, Atanas},
  journal={IEEE transactions on pattern analysis and machine intelligence},
  volume={40},
  number={1},
  pages={133--147},
  year={2017},
  publisher={IEEE}
}
```

The generation of different shearlet systems is controlled by two variables - `nScale` and `kSize`.
The setting of them depends on the disparity range of the input Sparsely-Sampled Light Field (SSLF) to be handled.
For differnt disparity ranges, we have the below suggestions:
- [0, 8] pixels -> `nScale = 3` and `kSize = 63`;
- [8, 16] pixels -> `nScale = 4` and `kSize = 127`;
- [16, 32] pixels -> `nScale = 5` and `kSize = 255`.

### References
```
@article{kutyniok2016shearlab,
  title={Shearlab 3D: Faithful digital shearlet transforms based on compactly supported shearlets},
  author={Kutyniok, Gitta and Lim, Wang-Q and Reisenhofer, Rafael},
  journal={ACM Transactions on Mathematical Software (TOMS)},
  volume={42},
  number={1},
  pages={1--42},
  year={2016},
  publisher={ACM New York, NY, USA}
}

@article{kutyniok2012shearlab,
  title={Shearlab: A rational design of a digital parabolic scaling algorithm},
  author={Kutyniok, Gitta and Shahram, Morteza and Zhuang, Xiaosheng},
  journal={SIAM Journal on Imaging Sciences},
  volume={5},
  number={4},
  pages={1291--1332},
  year={2012},
  publisher={SIAM}
}
```