entity mux2 is
  generic (len : integer);
  port (s : in bit;
        x, y : in bit_vector (0 to len-1);
        z : out bit_vector (0 to len-1));
end;

architecture behavioral of mux2 is
begin
  z <= y when s else x;
end;

component mux2
  generic (len : integer);
  port (s : in bit;
       x, y : in bit_vector (0 to len-1);
       z : out bit_vector (0 to len-1));
end;

entity and_gate is
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
        x : out bit_vector (0 to len-1));
end;

architecture behavioral of and_gate is
begin
  x <= y and z;
end;

component and_gate
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
       x : out bit_vector (0 to len-1));
end;

entity nand_gate is
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
        x : out bit_vector (0 to len-1));
end;

architecture behavioral of nand_gate is
begin
  x <= y nand z;
end;

component nand_gate
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
       x : out bit_vector (0 to len-1));
end;

entity nor_gate is
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
        x : out bit_vector (0 to len-1));
end;

architecture behavioral of nor_gate is
begin
  x <= y nor z;
end;

component nor_gate
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
       x : out bit_vector (0 to len-1));
end;

entity or_gate is
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
        x : out bit_vector (0 to len-1));
end;

architecture behavioral of or_gate is
begin
  x <= y or z;
end;

component or_gate
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
       x : out bit_vector (0 to len-1));
end;

entity xor_gate is
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
        x : out bit_vector (0 to len-1));
end;

architecture behavioral of xor_gate is
begin
  x <= y xor z;
end;

component xor_gate
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
       x : out bit_vector (0 to len-1));
end;

entity xnor_gate is
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
        x : out bit_vector (0 to len-1));
end;

architecture behavioral of xnor_gate is
begin
  x <= y xnor z;
end;

component xnor_gate
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
       x : out bit_vector (0 to len-1));
end;

entity not_gate is
  generic (len : integer);
  port (y : in bit_vector (0 to len-1);
        x : out bit_vector (0 to len-1));
end;

architecture behavioral of not_gate is
begin
  x <= not y;
end;

component not_gate
  generic (len : integer);
  port (y : in bit_vector (0 to len-1);
        x : out bit_vector (0 to len-1));
end;

entity da_reg is
  generic (lws, lbs : integer);
  port (a : in bit_vector (0 to 2**lws-1);
        c : in bit;
        d : in bit_vector (0 to 2**lbs-1);
        o : out bit_vector (0 to 2**lbs-1));
end;

architecture behavioral of da_reg is
begin
  base: if lws = 0 generate
    signal t : bit_vector (0 to 2**lbs-1);
  begin
    t <= d when a(0) and c else unaffected;
    o <= t when not c else unaffected;
  end;
  rec: if lws > 0 generate
  begin
    lhf : da_reg generic map (lws-1, lbs-1)
      port map (a(0 to 2**(lws-1)-1), c,
                d(0 to 2**(lbs-1)-1), o(0 to 2**(lbs-1)-1));
    hhf : da_reg generic map (lws-1, lbs-1)
      port map (a(2**(lws-1) to 2**lws-1), c,
                d(2**(lbs-1) to 2**lbs-1), o(2**(lbs-1) to 2**lbs-1));
  end;
end;

component da_reg
  generic (lws, lbs : integer);
  port (a : in bit_vector (0 to 2**lws-1);
        c : in bit;
        d : in bit_vector (0 to 2**lbs-1);
        o : out bit_vector (0 to 2**lbs-1));
end;
