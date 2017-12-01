-- sel is entire opcode
entity mmix_afu is
  generic (rsteps : integer);
  port (y, z, m, d, e, ai : in bit_vector (0 to 63);
        sel, ftr : in bit_vector (0 to 7);
        x, h, r, ao : out bit_vector (0 to 63);
        even, zero, negative, rnf, raise : out bit;
        which : out bit_vector (0 to 3));
end;

architecture a1 of mmix_afu is
  signal ixns, fxns, ppxns, pxns, exns, dxns, na : bit_vector (0 to 7);
  signal ires, fres : bit_vector (0 to 63);
  signal xa : bit_vector (0 to 3);
  signal xb, wh : bit_vector (0 to 1);
  signal isint, none : bit;

begin
  alpt : mmix_alu port map (y, z, m, d, ires, h, r, sel(1 to 6),
                            ixns(1), ixns(0), even, zero, negative);
  fppt : mmix_fpu generic map (rsteps) port map (e, y, z, ai(46 to 47),
                                                 sel(0)&sel(2 to 7), fres,
                                                 rnf, fxns);
  whun : mux2 generic map (72) port map (isint, fres&fxns, ires&ixns, x&ppxns);
  oxns : or_gate generic map (8) port map (ppxns, ftr, pxns);
  axns : and_gate generic map (8) port map (pxns, ai(48 to 55), exns);
  ang : not_gate generic map (8) port map (ai(48 to 55), na);
  anxs : and_gate generic map (8) port map (pxns, na, dxns);
  fai : or_gate generic map (8) port map (dxns, ai(56 to 63), ao(56 to 63));
  ahx : or_comb generic map (4) port map (exns(0 to 3), wh(0));
  hlx : mux2 generic map (4) port map (wh(0), exns(4 to 7), exns(0 to 3), xa);
  hla : mux2 generic map (2) port map (wh(1), xa(2 to 3), xa(0 to 1), xb);
  ixns(2 to 7) <= (others => '0');
  isint <= sel(1) or sel(2) or (sel(3) and sel(5) and not sel(0));
  ao(0 to 55) <= ai(0 to 55);
  raise <= xb(0) or xb(1);
  which <= none&wh&xb(0);
  wh(1) <= xa(0) or xa(1);
  none <= not (xb(0) or wh(0) or wh(1));
end;

component mmix_afu
  generic (rsteps : integer);
  port (y, z, m, d, e, ai : in bit_vector (0 to 63);
        sel, ftr : in bit_vector (0 to 7);
        x, h, r, ao : out bit_vector (0 to 63);
        even, zero, negative, rnf, raise : out bit;
        which : out bit_vector (0 to 3));
end;
