-- s is bits 2-6 of opcode
entity mmix_alu_arith is
  port (y, z, d : in bit_vector (0 to 63);
        x, h, r : out bit_vector (0 to 63);
        s : in bit_vector (0 to 4);
        oflow, idc : out bit);
end;

component mmix_alu_arith
  port (y, z, d : in bit_vector (0 to 63);
        x, h, r : out bit_vector (0 to 63);
        s : in bit_vector (0 to 4);
        oflow, idc : out bit);
end;

architecture a1 of mmix_alu_arith is
  signal mulx, divsx, divux, divx, mdx, ur, sr, mostx : bit_vector (0 to 63);
  signal addx, subx, cmpx, acx, asx, slx, srx, shx, ahx : bit_vector (0 to 63);
  signal ads1x, ads2x, ads3x, ads4x, adssx, adlsx, adsx : bit_vector (0 to 63);
  signal mulo, divo, mdo, addo, subo, ao, aso, shifto, lo, aslo, allo : bit;
  signal pidc, yh, zh, e, l : bit;
begin
  multiplier : mul_us generic map (64) port map (y, z, h, mulx, mulo);
  s_div : divider_s generic map (64) port map (y, z, divsx, sr, divo, pidc);
  u_div : divider generic map (64) port map (d&y, z, divux, ur);
  div_mx : mux2 generic map (128) port map (s(4), divsx&sr, divux&ur, divx&r);
  md_mx : mux2 generic map (65) port map (s(3), mulx&mulo, divx&divo, mdx&mdo);
  add : adder generic map (64) port map (y, z, addx, addo);
  comp : comparator generic map (64)
    port map (yh&y(1 to 63), zh&z(1 to 63), e, l);
  ac_mx : mux2 generic map (64) port map (s(1), addx, cmpx, acx);
  sub : subber generic map (64) port map (y, z, subx, subo);
  as_mx : mux2 generic map (65) port map (s(3), acx&ao, subx&subo, asx&aso);
  sl : lsh port map (y, z, slx, shifto);
  sr : rsh port map (y, z, s(4), srx, open);
  sh_mx : mux2 generic map (64) port map (s(3), slx, srx, shx);
  ads1 : adder generic map (64) port map (y(1 to 63)&1b"0", z, ads1x, open);
  ads2 : adder generic map (64) port map (y(2 to 63)&2b"0", z, ads2x, open);
  ss_mx : mux2 generic map (64) port map (s(4), ads1x, ads2x, adssx);
  ads3 : adder generic map (64) port map (y(3 to 63)&3b"0", z, ads3x, open);
  ads4 : adder generic map (64) port map (y(4 to 63)&4b"0", z, ads4x, open);
  ls_mx : mux2 generic map (64) port map (s(4), ads3x, ads4x, adlsx);
  ash_mx : mux2 generic map (64) port map (s(3), adssx, adlsx, adsx);
  hf_mx : mux2 generic map (64) port map (s(1), adsx, shx, ahx);
  most_mx : mux2 generic map (65) port map (s(2), asx&aso, ahx&lo, mostx&aslo);
  last_mx : mux2 generic map (65) port map (s(0), mdx&mdo, mostx&aslo, x&allo);
  ao <= addx and not s(1);
  zh <= z(0) xor s(4);
  yh <= y(0) xor s(4);
  cmpx <= (63 => not e, others => l and not e);
  lo <= shifto and s(1) and not s(3);
  oflow <= allo and not s(4);
  idc <= pidc and not s(0) and s(3) and not s(4);
end;

-- s is bits 3-6 of opcode
entity mmix_alu_logic is
  port (y, z, m : in bit_vector (0 to 63);
        x : out bit_vector (0 to 63);
        s : in bit_vector (0 to 3));
end;

component mmix_alu_logic
  port (y, z, m : in bit_vector (0 to 63);
        x : out bit_vector (0 to 63);
        s : in bit_vector (0 to 3));
end;

architecture a1 of mmix_alu_logic is
  signal spread3, zpb, orx, norx, xorx, xnrx, orxrx : bit_vector (0 to 63);
  signal andx, nandx, nxorx, xndx, nnxrx, gatex : bit_vector (0 to 63);
  signal bdx, wdx, tdx, odx, sdx, ldx, dfx : bit_vector (0 to 63);
  signal mxx, sadx, mdx, morx, mxx, mrxx, miscx, restx : bit_vector (0 to 63);
  signal mbar, my, mbarz : bit_vector (0 to 63);
begin
  czpb : xor_gate generic map (64) port map (z, spread3, zpb);
  org : or_gate generic map (64) port map (y, zpb, orx);
  norg : nor_gate generic map (64) port map (y, z, norx);
  xorg : xor_gate generic map (64) port map (y, z, xorx);
  xnrm : mux2 generic map (64) port map (s(3), norx, xorx, xnrx);
  orxrm : mux2 generic map (64) port map (s(2), orx, xnrx, orxrx);
  andg : and_gate generic map (64) port map (y, zpb, andx);
  nandg : nand_gate generic map (64) port map (y, z, nandx);
  nxorg : xnor_gate generic map (64) port map (y, z, nxorx);
  xndm : mux2 generic map (64) port map (s(3), nandx, nxorx, xndx);
  nnxrm : mux2 generic map (64) port map (s(2), andx, xndx, nnxrx);
  gatem : mux2 generic map (64) port map (s(1), orxrx, nnxrx, gatex);
  bd : bdif port map (y, z, bdx);
  wd : wdif port map (y, z, wdx);
  sd : mux2 generic map (64) port map (s(3), bdx, wdx, sdx);
  td : tdif port map (y, z, tdx);
  od : odif port map (y, z, odx);
  ld : mux2 generic map (64) port map (s(3), tdx, odx, ldx);
  df : mux2 generic map (64) port map (s(2), sdx, ldx, dfx);
  mx0 : not_gate generic map (64) port map (m, mbar);
  mx1 : and_gate generic map (64) port map (m, y, my);
  mx2 : and_gate generic map (64) port map (mbar, z, mbarz);
  mx3 : or_gate generic map (64) port map (my, mbarz, mxx);
  sad : sadd port map (andx, sadx);
  md : mux2 generic map (64) port map (s(3), mxx, sadx, mdx);
  mor : mor_mxor port map (y, z, morx, mxx);
  mrx : mux2 generic map (64) port map (s(3), morx, mxx, mrxx);
  misc : mux2 generic map (64) port map (s(2), mdx, mrxx, miscx);
  rest : mux2 generic map (64) port map (s(1), dfx, miscx, restx);
  allr : mux2 generic map (64) port map (s(0), gatex, restx, x);
  spread3 <= (others => s(3));
end;

-- s is bits 1-6 of opcode
entity mmix_alu is
   port (y, z, m, d : in bit_vector (0 to 63);
        x, h, r : out bit_vector (0 to 63);
        s : in bit_vector (0 to 5);
        oflow, idc, even, zero, negative : out bit);
end;

component mmix_alu
   port (y, z, m, d : in bit_vector (0 to 63);
        x, h, r : out bit_vector (0 to 63);
        s : in bit_vector (0 to 5);
        oflow, idc, even, zero, negative : out bit);
end;

architecture a1 of mmix_alu is
  signal ax, lx : bit_vector (0 to 63);
  signal o, d, nz : bit;
begin
  arith : mmix_alu_arith port map (y, z, d, ax, h, r, s(1 to 5), o, d);
  logic : mmix_alu_logic port map (y, z, m, lx, s(2 to 5));
  which : mux2 generic map (64) port map (s(0), ax, lx, x);
  any : or_comb generic map (64) port map (y, nz);
  oflow <= o and not s(0);
  idc <= d and not s(0);
  zero <= not nz;
  even <= not y(63);
  negative <= y(0);
end;
