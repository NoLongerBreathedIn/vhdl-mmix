entity mor_shuffle is
  port (z : in bit_vector (0 to 63);
        x : out bit_vector (0 to 63));
end;

architecture behavioral of mor_shuffle is
begin
  x <= z(00)&z(08)&z(16)&z(24)&z(32)&z(40)&z(48)&z(56)&
       z(01)&z(09)&z(17)&z(25)&z(33)&z(41)&z(49)&z(57)&
       z(02)&z(10)&z(18)&z(26)&z(34)&z(42)&z(50)&z(58)&
       z(03)&z(11)&z(19)&z(27)&z(35)&z(43)&z(51)&z(59)&
       z(04)&z(12)&z(20)&z(28)&z(36)&z(44)&z(52)&z(60)&
       z(05)&z(13)&z(21)&z(29)&z(37)&z(45)&z(53)&z(61)&
       z(06)&z(14)&z(22)&z(30)&z(38)&z(46)&z(54)&z(62)&
       z(07)&z(15)&z(23)&z(31)&z(39)&z(47)&z(55)&z(63) after 0 ns;
end;

component mor_shuffle
  port (z : in bit_vector (0 to 63);
        x : out bit_vector (0 to 63));
end;

entity mor_expand_z is
  port (z : in bit_vector (0 to 7);
        x : out bit_vector (0 to 63));
end;

architecture behavioral of mor_expand_z is
begin
  x <= (00 to 07 => z(0), 08 to 15 => z(1), 16 to 23 => z(2), 24 to 31 => z(3),
        32 to 39 => z(4), 40 to 47 => z(5), 48 to 55 => z(6), 56 to 63 => z(7))
       after 0 ns;
end;

component mor_expand_z
  port (z : in bit_vector (0 to 7);
        x : out bit_vector (0 to 63));
end;

entity mor_expand_y is
  port (y : in bit_vector (0 to 7);
        x : out bit_vector (0 to 63));
end;

architecture behavioral of mor_expand_y is
begin
  x <= y&y&y&y&y&y&y&y after 0 ns;
end;

component mor_expand_y
  port (y : in bit_vector (0 to 7);
        x : out bit_vector (0 to 63));
end;

entity mor_expand is
  port (y, z : in bit_vector (0 to 63);
        x : out bit_vector (0 to 511));
end;

architecture a1 of mor_expand is
  signal z_shuffle : bit_vector (0 to 63);
  signal z_expand, y_expand : bit_vector (0 to 511);
begin
  shuf : mor_shuffle port map (z, z_shuffle);
  stuff: for i in 0 to 7 generate
    zx : mor_expand_z port map (z_shuffle(i * 8, i * 8 + 7),
                                z_expand(i * 64, i * 64 + 63));
    yx : mor_expand_y port map (y(i * 8, i * 8 + 7),
                                y_expand(i * 64, i * 64 + 63));
  end;
  xg : and_gate generic map (512) port map (y_expand, z_expand, x);
end;

component mor_expand
  port (y, z : in bit_vector (0 to 63);
        x : out bit_vector (0 to 511));
end;

entity mor_mxor is
  port (y, z : in bit_vector (0 to 63);
        o, x : out bit_vector (0 to 63));
end;

architecture a1 of mor_mxor is
  signal lx : bit_vector (0 to 511);
  signal co0, cx0 : bit_vector (0 to 255);
  signal co1, cx1 : bit_vector (0 to 127);
begin
  eg : mor_expand port map (y, z, lx);
  o0 : or_gate generic map (256) port map (lx(0 to 255), lx(256 to 511), co0);
  o1 : or_gate generic map (128)
    port map (co0(0 to 127), co0(128 to 255), co1);
  o2 : or_gate generic map (64) port map (co1(0 to 63), lx(64 to 127), o);
  x0 : xor_gate generic map (256) port map (lx(0 to 255), lx(256 to 511), co0);
  x1 : xor_gate generic map (128)
    port map (co0(0 to 127), co0(128 to 255), co1);
  x2 : xor_gate generic map (64) port map (co1(0 to 63), lx(64 to 127), o);
end;

component mor_mxor
  port (y, z : in bit_vector (0 to 63);
        o, x : out bit_vector (0 to 63));
end;

entity comparator is
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
        e, l : out bit);
end;

component comparator
  generic (len : integer);
  port (y, z : in bit_vector (0 to len-1);
        e, l : out bit);
end;


architecture a1 of comparator is
begin
  base: if len = 1 generate
    e <= y(0) xor z(0);
    l <= z(0);
  end;
  rec: if len > 1 generate
    signal es, ls : bit_vector (0 to 1);
  begin
    ch : comparator generic map (len/2) port map (y(0 to len/2 - 1),
                                                  z(0 to len/2 - 1),
                                                  es(0), ls(0));
    cl : comparator generic map (len-len/2) port map (y(len/2 to len - 1),
                                                      z(len/2 to len - 1),
                                                      es(1), ls(1));
    e <= es(0) and es(1);
    l <= ls(1) when es(0) else ls(1);    
  end;
end;

entity sadd is
  port (y : in bit_vector (0 to 63);
        x : out bit_vector (0 to 63));
end;

architecture a1 of sadd is
  signal s1, s2 : bit_vector (0 to 63);
  signal s3, s4 : bit_vector (0 to 31);
  signal s5 : bit_vector (0 to 15);
begin
  step0: for i in 0 to 31 generate
    ha : halfadd port map (y(2*i), y(2*i+1), s1(2*i+1), s1(2*i));
  end;
  step1: for i in 0 to 15 generate
    ad1 : adder generic map (2)
      port map (s1(4*i to 4*i+1), s1(4*i+2 to 4*i+3),
                s2(4*i+2 to 4*i+3), s2(4*i+1));
    s2(4*i) <= '0';
  end;
  step2: for i in 0 to 7 generate
    ad2 : adder generic map (4)
      port map (s2(8*i to 8*i+3), s2(8*i+4 to 8*i+7),
                s3(4*i to 4*i+3), open);
  end;
  step3: for i in 0 to 3 generate
    ad3 : adder generic map (4)
      port map (s3(8*i to 8*i+3), s3(8*i+4 to 8*i+7),
                s4(8*i+4 to 8*i+7), s4(8*i+3));
    s4(8*i to 8*i+2) <= (others => '0');
  end;
  step4: for i in 0 to 1 generate
    ad4 : adder generic map (8)
      port map (s4(16*i to 16*i+7), s4(16*i+8 to 16*i+15),
                s5(8*i to 8*i+7), open);
  end;
  ad5 : adder generic map (8)
    port map (s5(0 to 7), s5(8 to 15), x(56 to 63), open);
  x(0 to 55) <= (others => 0);
end;

component sadd
  port (y : in bit_vector (0 to 63);
        x : out bit_vector (0 to 63));
end;

entity bdif is
  port (y, z : in bit_vector (0 to 63);
        x : out bit_vector (0 to 63));
end;

architecture a1 of bdif is
  signal nz : bit_vector (0 to 63);
begin
  ntg : not_gate generic map (64) port map (z, nz);
  oneb: for i in 0 to 7 generate
    signal s : bit_vector(0 to 7);
    signal c : bit;
  begin
    sub : adder_1 generic map (8)
      port map (y(8*i to 8*i+7), nz(8*i to 8*i+7), s, c);
    x(8*i to 8*i+7) <= s when c else 8b"0";
  end;
end;
      
component bdif
  port (y, z : in bit_vector (0 to 63);
        x : out bit_vector (0 to 63));
end;

entity wdif is
  port (y, z : in bit_vector (0 to 63);
        x : out bit_vector (0 to 63));
end;

architecture a1 of wdif is
  signal nz : bit_vector (0 to 63);
begin
  ntg : not_gate generic map (64) port map (z, nz);
  oneb: for i in 0 to 3 generate
    signal s : bit_vector(0 to 15);
    signal c : bit;
  begin
    sub : adder_1 generic map (16)
      port map (y(16*i to 16*i+15), nz(16*i to 16*i+15), s, c);
    x(16*i to 16*i+15) <= s when c else 16b"0";
  end;
end;
      
component wdif
  port (y, z : in bit_vector (0 to 63);
        x : out bit_vector (0 to 63));
end;

entity tdif is
  port (y, z : in bit_vector (0 to 63);
        x : out bit_vector (0 to 63));
end;

architecture a1 of tdif is
  signal nz : bit_vector (0 to 63);
begin
  ntg : not_gate generic map (64) port map (z, nz);
  oneb: for i in 0 to 1 generate
    signal s : bit_vector(0 to 31);
    signal c : bit;
  begin
    sub : adder_1 generic map (32)
      port map (y(32*i to 32*i+31), nz(32*i to 32*i+31), s, c);
    x(32*i to 32*i+31) <= s when c else 32b"0";
  end;
end;
      
component tdif
  port (y, z : in bit_vector (0 to 63);
        x : out bit_vector (0 to 63));
end;

entity odif is
  port (y, z : in bit_vector (0 to 63);
        x : out bit_vector (0 to 63));
end;

architecture a1 of odif is
  signal nz, s : bit_vector (0 to 63);
  signal c : bit;
begin
  ntg : not_gate generic map (64) port map (z, nz);
  sub : adder_1 generic map (64)
    port map (y, nz, s, c);
  x <= s when c else 64b"0";
end;
      
component odif
  port (y, z : in bit_vector (0 to 63);
        x : out bit_vector (0 to 63));
end;

entity or_comb is
  generic (len : integer);
  port (y : in bit_vector (0 to len-1);
        x : out bit);
end;

component or_comb
  generic (len : integer);
  port (y : in bit_vector (0 to len-1);
        x : out bit);
end;

architecture a1 of or_comb is
begin
  base: if len = 1 generate
    x <= y(0);
  end;
  reco: if len > 1 and len rem 2 = 1 generate
    signal s : bit_vector (0 to (len-1)/2-1);
  begin
    og : or_gate generic map ((len-1)/2) port map (y(0 to (len-1)/2-1),
                                                   y((len-1)/2 to len-2),
                                                   s);
    oc : or_comb generic map ((len+1)/2) port map (s&y(len-1), x);
  end;
  rece: if len > 1 and len rem 2 = 1 generate
    signal s : bit_vector (0 to len/2-1);
  begin
    og : or_gate generic map (len/2) port map (y(0 to len/2-1),
                                               y(len/2 to len-1),
                                               s);
    oc : or_comb generic map (len/2) port map (s, x);
  end;
end;

entity and_comb is
  generic (len : integer);
  port (y : in bit_vector (0 to len-1);
        x : out bit);
end;

component and_comb
  generic (len : integer);
  port (y : in bit_vector (0 to len-1);
        x : out bit);
end;

architecture a1 of and_comb is
begin
  base: if len = 1 generate
    x <= y(0);
  end;
  reco: if len > 1 and len rem 2 = 1 generate
    signal s : bit_vector (0 to (len-1)/2-1);
  begin
    og : and_gate generic map ((len-1)/2) port map (y(0 to (len-1)/2-1),
                                                   y((len-1)/2 to len-2),
                                                   s);
    oc : and_comb generic map ((len+1)/2) port map (s&y(len-1), x);
  end;
  rece: if len > 1 and len rem 2 = 1 generate
    signal s : bit_vector (0 to len/2-1);
  begin
    og : and_gate generic map (len/2) port map (y(0 to len/2-1),
                                               y(len/2 to len-1),
                                               s);
    oc : and_comb generic map (len/2) port map (s, x);
  end;
end;


entity lsh is
  port (y, z : in bit_vector (0 to 63);
        x : out bit_vector (0 to 63);
        c : out bit);
end;

architecture a1 of lsh is
  signal s0, s1, s2, s3, s4, s5 : bit_vector (0 to 63);
  signal cs : bit_vector (0 to 5);
  signal as : bit_vector (0 to 5);
  signal hiz, cj : bit;
begin
  step0 : mux2 generic map (65)
    port map (z(63), '0'&y, y&'0', cs(0)&s0);
  o1 : or_comb generic map (2) port map (s0(0 to 1), as(0));
  step1 : mux2 generic map (65)
    port map (z(62), '0'&s0, as(0)&s0(2 to 63)&2b"0", cs(1)&s1);
  o2 : or_comb generic map (4) port map (s1(0 to 3), as(1));
  step2 : mux2 generic map (65)
    port map (z(61), '0'&s1, as(1)&s1(4 to 63)&4b"0", cs(2)&s2);
  o3 : or_comb generic map (8) port map (s2(0 to 7), as(2));
  step3 : mux2 generic map (65)
    port map (z(60), '0'&s2, as(2)&s2(8 to 63)&8b"0", cs(3)&s3);
  o4 : or_comb generic map (16) port map (s3(0 to 15), as(3));
  step4 : mux2 generic map (65)
    port map (z(59), '0'&s3, as(3)&s3(16 to 63)&16b"0", cs(4)&s4);
  o5 : or_comb generic map (32) port map (s4(0 to 31), as(4));
  step5 : mux2 generic map (65)
    port map (z(58), '0'&s4, as(4)&s4(32 to 63)&32b"0", cs(5)&s5);
  o6 : or_comb generic map (64) port map (y, as(5));
  o7 : or_comb generic map (64) port map (z(0 to 57)&6b"0", hiz);
  o8 : or_comb generic map (8) port map (cs&2b"0", cj);
  step6 : mux2 generic map (65)
    port map (hiz, cj&s5, as(5)&64b"0", c&x);
end;

component lsh
  port (y, z : in bit_vector (0 to 63);
        x : out bit_vector (0 to 63);
        c : out bit);
end;

entity rsh is
  port (y, z : in bit_vector (0 to 63);
        s : in bit;
        x : out bit_vector (0 to 63);
        i : out bit);
end;

architecture a1 of rsh is
  signal sbits, s0, s1, s2, s3, s4, s5 : bit_vector(0 to 64);
  signal hiz, lo2, lo4, lo8, lo16, lo32, lo64 : bit;
begin
  step0 : mux2 generic map (65)
    port map (z(63), y&'0', sbits(0)&y, s0);
  o1 : or_comb generic map (2) port map (s0(62 to 63), lo2);
  step1 : mux2 generic map (65)
    port map (z(62), s0, sbits(0 to 1)&s0(0 to 61)&lo2, s1);
  o2 : or_comb generic map (4) port map (s1(60 to 63), lo4);
  step2 : mux2 generic map (65)
    port map (z(61), s1, sbits(0 to 3)&s1(0 to 59)&lo4, s2);
  o3 : or_comb generic map (8) port map (s2(56 to 63), lo8);
  step3 : mux2 generic map (65)
    port map (z(60), s2, sbits(0 to 7)&s2(0 to 55)&lo8, s3);
  o4 : or_comb generic map (16) port map (s3(48 to 63), lo16);
  step4 : mux2 generic map (65)
    port map (z(59), s3, sbits(0 to 15)&s3(0 to 47)&lo16, s4);
  o5 : or_comb generic map (32) port map (s4(32 to 63), lo32);
  step5 : mux2 generic map (65)
    port map (z(58), s4, sbits(0 to 31)&s4(0 to 31)&lo32, s5);
  ohz : or_comb generic map (65) port map (z(0 to 57)&6b"0", hiz);
  o6 : or_comb generic map (64) port map (y, lo64);
  step6 : mux2 generic map (65)
    port map (hiz, s5, sbits, x&i);
  sbits <= (64 => lo64,
            others => y(0) and s);
end;

component rsh
  port (y, z : in bit_vector (0 to 63);
        s : in bit;
        x : out bit_vector (0 to 63),
        i : out bit);
end;
