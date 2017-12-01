entity halfadd_1 is
  port (y, z : in bit;
        x, c : out bit);
end;

architecture a1 of halfadd_1 is
begin
  x <= y xnor z;
  c <= y or z;
end;

component halfadd_1
  port (y, z : in bit;
        x, c : out bit);
end;

entity halfadd is
  port (y, z : in bit;
        x, c : out bit);
end;

architecture a0 of halfadd is
begin
  x <= y xor z;
  c <= y and z;
end;

component halfadd
  port (y, z : in bit;
        x, c : out bit);
end;

entity fulladd is
  port (y, z, w : in bit;
        x, c : out bit);

architecture a1 of fulladd is
begin
  x <= y xor z xor w;
  c <= (y and (z or w)) or (z and w);
end;

component fulladd
  port (y, z, w : in bit;
        x, c : out bit);
end;

entity adder is
  generic (len : integer);
  port (y, z : in bit_vector (0 to len - 1);
        x : out bit_vector (0 to len - 1);
        c : out bit);
end;

component adder
  generic (len : integer);
  port (y, z : in bit_vector (0 to len - 1);
        x : out bit_vector (0 to len - 1);
        c : out bit);
end;

entity adder_1 is
  generic (len : integer);
  port (y, z : in bit_vector (0 to len - 1);
        x : out bit_vector (0 to len - 1);
        c : out bit);
end;

component adder_1
  generic (len : integer);
  port (y, z : in bit_vector (0 to len - 1);
        x : out bit_vector (0 to len - 1);
        c : out bit);
end;

architecture a1 of adder is
begin
  low: if len = 2 generate
    signal ci : bit;
  begin
    add0 : halfadd port map (y(1), z(1), x(1), ci);
    add1 : fulladd port map (y(0), z(0), ci, x(0), c);
  end;
  base: if len = 4 generate
    signal cs : bit_vector (0 to 2);
  begin
    add0 : halfadd port map (y(3), z(3), x(3), cs(2));
    add1 : fulladd port map (y(2), z(2), cs(2), x(2), cs(1));
    add2 : fulladd port map (y(1), z(1), cs(1), x(1), cs(0));
    add3 : fulladd port map (y(0), z(0), cs(0), x(0), c);
  end;
  rec: if len > 4 generate
    signal ci : bit;
    signal x0, x1: bit_vector (0 to len/2);
  begin
    al : adder generic map (len/2)
      port map (y(len/2 to len-1), z(len/2 to len-1), x(len/2 to len-1), ci);
    ah0 : adder generic map (len/2)
      port map (y(0 to len/2-1), z(0 to len/2-1), x0(0 to len/2-1), x0(len/2));
    ah1 : adder_1 generic map (len/2)
      port map (y(0 to len/2-1), z(0 to len/2-1), x1(0 to len/2-1), x1(len/2));
    mx : mux2 generic map (len/2+1) port map (ci, x0, x1, x(0 to len/2-1)&c);
  end;
end;

architecture a1 of adder_1 is
begin
  low: if len = 2 generate
    signal ci : bit;
  begin
    add0 : halfadd_1 port map (y(1), z(1), x(1), ci);
    add1 : fulladd port map (y(0), z(0), ci, x(0), c);
  end;
  base: if len = 4 generate
    signal cs : bit_vector (0 to 2);
  begin
    add0 : halfadd_1 port map (y(3), z(3), x(3), cs(2));
    add1 : fulladd port map (y(2), z(2), cs(2), x(2), cs(1));
    add2 : fulladd port map (y(1), z(1), cs(1), x(1), cs(0));
    add3 : fulladd port map (y(0), z(0), cs(0), x(0), c);
  end;
  rec: if len > 4 generate
    signal ci : bit;
    signal x0, x1: bit_vector (0 to len/2);
  begin
    al : adder_1 generic map (len/2)
      port map (y(len/2 to len-1), z(len/2 to len-1), x(len/2 to len-1), ci);
    ah0 : adder generic map (len/2)
      port map (y(0 to len/2-1), z(0 to len/2-1), x0(0 to len/2-1), x0(len/2));
    ah1 : adder_1 generic map (len/2)
      port map (y(0 to len/2-1), z(0 to len/2-1), x1(0 to len/2-1), x1(len/2));
    mx : mux2 generic map (len/2+1) port map (ci, x0, x1, x(0 to len/2-1)&c);
  end;
end;

entity subber is
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
        x : out bit_vector (0 to len-1);
        o : out bit);
end;

architecture a1 of subber is
  signal zbar : bit_vector (0 to len-1);
  signal xhi : bit;
begin
  zn : not_gate generic map (len) port map (z, zbar);
  adr : adder_1 generic map (len) port map (y, z, xhi&x(1 to len-1));
  x(0) <= xhi;
  o <= (y(0) xor z(0)) and (y(0) xor xhi);

component subber
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
        x : out bit_vector (0 to len-1);
        o : out bit);
end;
