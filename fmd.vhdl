entity fmul is
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt, r : in bit_vector (0 to 1);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));
end;

architecture a1 of fmul is
  signal xf, xm, mh, ml, nfres : bit_vector (0 to 63);
  signal xe0, xe : bit_vector (0 to 15);
  signal pxns : bit_vector (0 to 7);
  signal xs, infml, finml, i_bit, lmnz, lmnza, lgf, smf : bit;
begin
  mult : mul generic map (64) (yf, zf(9 to 63)&9b"0", mh&ml);
  xflg : or_comb generic map (10) port map (mh(0 to 9), lgf);
  olow : or_comb generic map (64) port map (ml, lmnz);
  dxf : mux2 generic map (64) port map (lgf, mh(1 to 63)&lmnza,
                                        mh(0 to 62)&lmnz, xf);
  ad0 : adder generic map (16) port map (ye, ze, xe0, open);
  ad1 : adder generic map (16) port map (xe0, o"77001"&smf, xe, open);
  pk : fpack port map (xf, xe, xs, r, xm, pxns);
  fmx : mux2 generic map (72) port map (finml, nfres&o"0"&i_bit&h"0",
                                        xm&pxns, x&exns);
  infml <= yt(0) or zt(0);
  xs <= ys xor zs;
  lmnza <= mh(63) or lmnz;
  smf <= not lgf;
  i_bit <= infml and ((yt(0) nor yt(1)) or (zt(0) nor zt(1)));
  finml <= not infml and yt(1) and zt(1);
  nfres <= (0 => xs,
            1 to 11 => infml,
            12 => i_bit,
            others => '0');
end;

component fmul
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt, r : in bit_vector (0 to 1);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));
end;

entity fdiv is
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt, r : in bit_vector (0 to 1);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));
end;

architecture a1 of fdiv is
  signal xf, xd, q, r, nfres : bit_vector (0 to 63);
  signal pxns : bit_vector (0 to 7);
  signal xe0, xe, zeb : bit_vector (0 to 15);
  signal findv, infdv, i_bit, z_bit, lgf, rnz, rnza : bit;
begin
  dvd : divider generic map (64) port map (yf&64b"0", zf, q, r);
  xflg : or_comb generic map (9) port map (q(0 to 8), lgf);
  zng : not_gate generic map (16) port map (ze, zeb);
  ad0 : adder generic map (16) port map (ye, zeb, xe0, open);
  ad1 : adder generic map (16) port map (o"00777"&lgf, xe0, xe, open);
  rnzc : or_comb generic map (65) port map (q(63)&r, rnz);
  xfml : mux2 generic map (64) port map (lgf, q(0 to 62)&rnz,
                                         '0'&q(0 to 61)&rnza,
                                         xf);
  pk : fpack port map (xf, xe, xs, r, xd, pxns);
  fmx : mux2 generic map (72) port map (findv, nfres&o"0"&i_bit&'0'&z_bit&'0',
                                        xd&pxns, x&exns);
  rnza <= rnz or q(62);
  nfres <= (0 => xs,
            1 to 11 => infdv,
            12 => i_bit,
            others => '0');
  infdv <= yt(0) or (zt(0) nor zt(1));
  i_bit <= (yt(0) xor zt(0)) nor (yt(1) xor zt(1));
  z_bit <= yt(1) and not zt(0);
  findv <= yt(1) and zt(1);
end;

component fdiv
  port (yf : in bit_vector (0 to 63);
        ye : in bit_vector (0 to 15);
        ys : in bit;
        yt : in bit_vector (0 to 1);
        zf : in bit_vector (0 to 63);
        ze : in bit_vector (0 to 15);
        zs : in bit;
        zt, r : in bit_vector (0 to 1);
        x : out bit_vector (0 to 63);
        exns : out bit_vector (0 to 7));
end;
