entity divstep is
  generic (len : integer);
  port (dividend_i : in bit_vector (0 to 2*len-1);
        dividend_o : out bit_vector (0 to 2*len-1);
        db : in bit_vector (0 to len-1));
end;

architecture a1 of divstep is
  signal c : bit;
  signal difference : bit_vector (0 to len-1);
begin
  sbr : adder_1 generic map (len)
    port map (dividend_i(0 to len-1), db, difference, c);
  rmux : mux2 generic map (len-1) port map (c, difference(1 to len-1),
                                            dividend_i(1 to len-1),
                                            dividend_o(0 to len-2));
  dividend_o(len-1 to 2*len-2) <= dividend_i(len to 2*len-1);
  dividend_o(2*len-1) <= c;
end;

component divstep
  generic (len : integer);
  port (dividend_i : in bit_vector (0 to 2*len-1);
        dividend_o : out bit_vector (0 to 2*len-1);
        divisor : in bit_vector (0 to len-1));
end;

entity divider is
  port (dividend : in bit_vector (0 to 2*len-1);
        divisor : in bit_vector (0 to len-1);
        quotient, remainder : out bit_vector (0 to len-1));
end;

architecture a1 of divider is
  type intermediate is array (0 to len) of bit_vector (0 to 2*len-1);
  signal s : intermediate;
  signal c, e, l : bit;
  signal db : bit_vector (0 to len-1);
begin
  dv : for i in 0 to len-1 generate
    di : divstep generic map(len) port map (s(i), s(i+1), db);
  end;
  ng : not_gate generic map (len) port map (divisor, db);
  cmp : comparator generic map (len)
    port map (divisor, dividend(0 to len-1), e, l);
  mx : mux2 generic map (2*len)
    port map (c, s(len), dividend, quotient&remainder);
  c <= e or l;
  s(0) <= dividend;
end;

component divider
  generic (len : integer);
  port (dividend : in bit_vector (0 to 2*len-1);
        divisor : in bit_vector (0 to len-1);
        quotient, remainder : out bit_vector (0 to len-1));
end;


entity divider_s is
  generic (len : integer);
  port (dividend, divisor : in bit_vector (0 to len-1);
        quotient, remainder : out bit_vector (0 to len-1);
        oflow, divcheck : out bit);
end;

architecture a1 of divider_s is
  signal ybar, yya, yy, zbar, zza, zz, q, r, qq, rr : bit_vector (0 to len-1);
  signal qbar, qneg, rbar, rneg, zx, mz, rpz, r0, fq : bit_vector (0 to len-1);
  signal dcbar, both, one, ar, usb, some, arr : bit;
begin
  dcheck : or_comb generic map (len) port map (divisor, dcbar);
  ynt : not_gate generic map (len) port map (dividend, ybar);
  znt : not_gate generic map (len) port map (divisor, zbar);
  ysf : adder_1 generic map (len) port map (y => (others => 0),
                                            z => ybar,
                                            x => yya,
                                            c => open);
  zsf : adder_1 generic map (len) port map (y => (others => 0),
                                            z => zbar,
                                            x => zza,
                                            c => open);
  ysl : mux2 generic map (len) port map (y(0), dividend, yya, yy);
  zsl : mux2 generic map (len) port map (z(0), divisor, zza, zz);
  divver : divider generic map (len)
    port map (dividend(0 to len-1) => (others => 0),
              dividend(len to 2*len) => yy,
              divisor => zz,
              quotient => q,
              remainder => r);
  qnt : not_gate generic map (len) port map (q, qbar);
  qsf : adder_1 generic map (len) port map (y => (others => 0),
                                            z => qbar,
                                            x => qneg,
                                            c => open);
  rnt : not_gate generic map (len) port map (r, rbar);
  rsf : adder_1 generic map (len) port map (mz, rbar, rneg, open);
  mzc : and_gate generic map (len) port map (zx, divisor, mz);
  arc : or_comb generic map (len) port map (r, ar);
  arz : adder generic map (len) port map (r, divisor, rpz, open);
  r0m : mux2 generic map (len) port map (divisor(0), rpz, rneg, r0);
  rrm : mux2 generic map (len) port map (usb, r, r0, rr);
  rra : or_comb generic map (len) port map (rr, arr);
  qqc : mux2 generic map (len) port map (arr, qneg, qbar, qq);
  fqc : mux2 generic map (len) port map (one, q, qq, fq);
  fmx : mux2 generic map (2*len) port map (s => dcbar,
                                           x(0 to len-1) => (others => 0),
                                           x(len to 2*len-1) => dividend,
                                           y => fq&rr,
                                           z => quotient&remainder);
  one <= dividend(0) xor divisor(0);
  both <= dividend(0) and divisor(0);
  some <= dividend(0) or divisor(0);
  zx <= (others => not divisor(0));
  usb <= (both or ar) and some;
  oflow <= q(0) and both;
  divcheck <= not dcbar;
end;

component divider_s
  generic (len : integer);
  port (dividend, divisor : in bit_vector (0 to len-1);
        quotient, remainder : out bit_vector (0 to len-1);
        oflow, divcheck : out bit);
end;
