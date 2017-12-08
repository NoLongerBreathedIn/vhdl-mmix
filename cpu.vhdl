-- Microarchitecture:
-- There are 256 bregisters (0 to 0xFF). All are one-byte.
-- These can also be treated as 128 one-wyde wregisters (0 to 0x7F),
-- or as 64 one-tetra tregisters (0 to 077),
-- or as 32 one-octa oregisters (0 to 31).
-- There are 128 iflags (set by other hardware, testable by cpu)
-- There are 256 oflags (set by cpu, testable by other hardware).
-- There are 65536 instructions.
-- Instructions are 19 bits long.
-- Format:
--
--  0                   1
--  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8
-- +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-- | INS |       X       |       Y       |
-- +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
--
-- Instructions:
-- 0: MVB X Y Move byte from bregister Y to bregister X.
-- 1: MVW X/2 Y/2 Move wyde from wregister Y/2 to wregister X/2.
-- 2: MVT X/4 Y/4 Move tetra from tregister Y/4 to tregister X/4.
-- 3: MVO X/8 Y/8 Move octa from oregister Y/8 to oregister X/8.
-- 4: SET X Y Set contents of bregister X to Y.
-- 5: BIF X Y If iflag Y is on, skip X instructions,
-- treating X as two's complement. X may not be 0; that would be a no-op.
-- 6: PGO XY+1 Push microcode pointer
-- and jump to location XY+1 (mod 65536).
-- 7: POP Pop microcode pointer, then increment it. X must be 0.
-- Other instructions:
-- AST Y Assert oflag y. Encoded as 5 00 Y.
-- CLW Y/2 Set contents of wregister Y/2 to 0. This is encoded as 7 01 Y.
-- CLT Y/4 Set contents of tregister Y/4 to 0. This is encoded as 7 02 Y.
-- CLO Y/8 Set contents of oregister Y/8 to 0. This is encoded as 7 03 Y.
-- CJP Y/2 Jump to contents of wregister Y/2, but skip an instruction.
-- This is encoded as 7 04 Y.
-- Currently (not likely to change, but why rely on this?),
-- only the last three bits of X affect what 7 X Y does.
-- If they're 0, it's POP, 4 it's CJP.
-- 1 or 5 it's CLW, 2 or 6 it's CLT, 3 or 7 it's CLO.
-- BUN X Y Jumps in same way as BIF, except if Y is off.
-- This is encoded as 4 X (Y+80)
--
-- Special registers:
-- Bregister 0 is the ALU selector.
-- Bregister 1 is the special register selector (SRS).
-- Bregister 2 is rG.
-- Bregister 3 is rL.
-- Tregister 1 (bregs 4-7) has no special meaning,
-- and should be used for the instruction.
-- Oregister 1 (bregs 8-F) is ALU inregister Y.
-- Oregister 2 (bregs 10-17) is ALU inregister Z.
-- Oregister 3 (bregs 18-1F) is ALU out, and cannot be written to. (ror)
-- Oregister 4 (bregs 20-27) is the special data register.
-- It is wired to special register SRS%32.
-- Oregister 5 (bregs 28-2F) is the general data register.
-- It is wired to general register GRS.
-- Oregister 6 (bregs 30-37) is the memory access register (MAR).
-- Oregister 7 (bregs 38-3F) is the memory data register (MDR).
-- Bregisters 40 to 43 are the first four nybbles of rV. (ror)
-- Wregisters 22 and 23 (bregs 44-47) are for page tables.
-- Put a wyde into 22, read bits 3-12 out of bits 3-12 of 23. (ror)
-- Bits 13-15 are put into iflags.
-- Bregister 48 is the general register selector (GRS).
-- Oregister 9 except for its high byte (bregs 49-4F)
-- and wregs 28-2C (bregs 50-59) are the base-1024 handler.
-- Put ABCDE (base 1024) into oreg 9, read A from wreg 28, B from wreg 29, etc.
-- These are read-only, and the bits set are 3-12.
-- Wregister 2D (bregs 5A,5B) is bits 51-63 of rV. (ror)
-- Tregister 027 (bregs 5C-5F) is bits 24-50 of rV. (ror)
-- Bregister 60 causes arithmetic exceptions.
-- The exceptions raised are those raised by the ALU and FPU normally,
-- together with those in 60.
-- Bregister 61 is the leftmost enabled and triggered arithmetic exception,
-- in bits 1 to 3. Bits 4-7 are off; bit 0 is on if bits 1-3 are off. (ror)
-- Bregister 62 is the third byte of rV. (ror)
-- Oregister 12, except for its high three bytes (bregs 63-67),
-- is the translation cache value register (TCVR).
-- Oregister 13 (bregs 68-6F) is the translation cache key register (TCKR).
-- Oregister 14 (bregs 70-77) should probably be used
-- for the instruction pointer. It has no special meaning.
-- Oregisters 15-18 (bregs 78-97) contain rO, rS, rI, rU in that order.
-- Oregister 19 (bregs 98-9F) contains L(y) - see p. 49 of MMIXware.
-- Bregister FF is copied into iflags 10-17.
-- Remaining registers have no special meaning; plenty of those.
--
-- Iflags:
-- Iflag 0 is the ALU even flag.
-- Iflag 1 is the ALU zero flag.
-- Iflag 2 is the ALU negative flag.
-- Iflag 3 is the ALU error flag.
-- Iflag 4 is the ALU frem-not-finished flag.
-- Iflag 5 is on if rQ&rK is nonzero.
-- Iflag 6 is on if the instruction translation cache contains the TCAR.
-- Iflag 7 is like iflag 6, except data instead of instructions.
-- Iflags 8-A are bits 13-15 of wreg 22.
-- Iflag B is on if all program bits of rK are.
-- Iflag C is the memory-not-finished flag. This is related only to the last
-- memory operation.
-- Iflag D is always off.
-- Iflags 10-17 are the bits of breg FF.
-- Iflags 18-1F are the program bits of rK.
-- The remaining iflags are currently unassigned.
--
-- Oflags:
-- Oflags 0-7 force on the corresponding program bits (rwxnkbsp) of rQ;
-- oflag 6 also forces on the s bit of rK.
-- Oflag 8 sets MDR = m8[MAR] (memory read). This is treated as data.
-- Oflag 9 sets m8[MAR] = MDR (memory write).
-- (The high bit of MAR is ignored.)
-- Oflag A clears the data cache block containing MAR
-- by setting its LU time to 0.
-- Oflag B preloads the data cache from memory locations
-- between MAR and MDR inclusive.
-- Oflag C preloads the instruction cache from memory locations
-- between MAR and MDR inclusive.
-- Oflag D deletes references in the data cache for memory locations between
-- MAR and MDR inclusive; this only affects cache blocks entirely between them,
-- and does force writing.
-- Oflag E locks m8[MAR] and forces cache skips.
-- Oflag F unlocks the memory.
-- Oflag 10 cleans all dirty blocks in the data cache.
-- Oflag 11 sleeps the machine.
-- Oflag 12 deletes the entire data cache. Dirty blocks are not written.
-- Oflag 13 cleans the data cache for memory locations between MAR and MDR
-- inclusive; this affects any cache block overlapping that area,
-- and forces writing.
-- Oflag 14 is like oflag D, except the cache blocks affected are those for
-- oflag 13.
-- Oflag 15 clears the instruction cache; blocks affected are as in 13.
-- Oflag 16 deletes the entire instruction cache.
-- Oflag 17 sets TCVR = ITC[TCKR]
-- Oflag 18 sets ITC[TCKR] = TCVR
-- Oflag 19 sets the last three bits of ITC[TCVR] to those of
-- TCVR if they are not all 0. Otherwise, it deletes ITC[TCVR].
-- Oflags 1A-1C act like 17-19, except they work with the DTC.
-- Oflag 1D deletes the entire ITC and DTC.
-- Oflag 1E forces on the seventh-to-last bit of rQ.
-- Oflag 1F sets rR.
-- Oflag 20 sets rH.
-- Oflag 21 sets rA.
-- Oflag 22 acts like oflag 24, except it's for instruction reads.
-- Oflag 23 acts like oflag 13, except it doesn't write
-- Oflags 24-26 set MDR <= m4[MAR]/m2[MAR]/m1[MAR].
-- The remaining oflags are currently unassigned.
-- Standard idiom for reading/writing/frobbing memory is
-- 5 00 Y (AST Y)
-- 5 FF 0C (BIF -1 C)
-- where the second instruction may be omitted if Y is A-C, 12, 15, 16, or 23,
-- as those never cause busyness.

type ucode is array (0 to 65535) of bit_vector (0 to 18);
type ureg is array (0 to 32) of bit_vector (0 to 63);
type eightb is array (0 to 8) of bit_vector (0 to 8);

entity mmix_cpu_core is
  port (code : in ucode;
        iflags : in bit_vector (0 to 127);
        uregs : in ureg;
        uptri, nstk : in bit_vector (0 to 15);
        oregs : out bit_vector (0 to 63);
        wtb, oflags : out bit_vector (0 to 255);
        pshstk, popstk : out bit;
        uptro : out bit_vector (0 to 15));
end;

architecture a1 of mmix_cpu_core is
  signal uop : bit_vector (0 to 2);
  signal instx, insty, my, hix, wrp : bit_vector (0 to 7);
  signal yread0, yread1, yread2, yread3 : bit_vector (0 to 63);
  signal wro, wrt, wrw, wrb, wrot, wrwb : bit_vector (0 to 255);
  signal l0, r0, l1, r1, l2, r2, setreg, anyx, doot, doow, icj : bit;
  signal dbr, rdbr, iporp, dast, wry : bit;
  signal incamt, uptrr, uptrs, uptr0 : bit_vector (0 to 15);
begin
  fetch : muxn generic map (19, 16) port map (code, uptri, uop&instx&insty);
  ry : muxn generic map (63, 5) port map (ureg, y(0 to 4), yread0);
  col0: for i in 0 to 3 generate
  begin
    lmx0 : mux2 generic map (8) port map (l0, yread0(i*16 to i*16+7),
                                          yread0(i*16+8 to i*16+15),
                                          yread1(i*16 to i*16+7));
    rmx0 : mux2 generic map (8) port map (r0, yread0(i*16 to i*16+7),
                                          yread0(i*16+8 to i*16+15),
                                          yread1(i*16+8 to i*16+15));
  end;
  col1: for i in 0 to 1 generate
  begin
    lmx1 : mux2 generic map (16) port map (l1, yread1(i*32 to i*32+15),
                                           yread1(i*32+16 to i*32+31),
                                           yread2(i*32 to i*32+15));
    rmx1 : mux2 generic map (16) port map (r1, yread1(i*32 to i*32+15),
                                           yread1(i*32+16 to i*32+31),
                                           yread2(i*32+16 to i*32+31));
  end;
  lmx2 : mux2 generic map (32) port map (l2, yread2(0 to 31),
                                         yread2(32 to 63),
                                         yread3(0 to 31));
  rmx2 : mux2 generic map (32) port map (r2, yread2(0 to 63),
                                         yread2(32 to 63),
                                         yread3(32 to 63));
  mymx : mux2 generic map (8) port map (uop(1), insty, h"00", my);
  forg : mux2 generic map (64) port map (uop(0), yread3,
                                         my&my&my&my&my&my&my&my,
                                         oregs);
  ianyx : or_comb generic map (8) port map (instx, anyx);
  whtw : mux2 generic map (8) port map (wry, instx, insty, wrp);
  who : dmxn generic map (3, 5) port map (wrp(0 to 4), setreg, wro);
  wht : dmxn generic map (2, 6) port map (wrp(0 to 5), setreg, wrt);
  whw : dmxn generic map (1, 7) port map (wrp(0 to 6), setreg, wrw);
  whb : dmxn generic map (0, 8) port map (wrp, setreg, wrb);
  mot : mux2 generic map (256) port map (doow, wrt, wro, wrot);
  mwb : mux2 generic map (256) port map (doow, wrb, wrw, wrwb);
  mwtb : mux2 generic map (256) port map (doot, wrwb, wrot, wtb);
  ibr : mux1 generic map (7) port map (iflags, insty(1 to 7), dbr);
  ciam : mux2 generic map (16) port map (rdbr, 16b"0", hix&instx, incamt);
  wuptrr : mux2 generic map (16) port map (instx(5), nstk, yread3(0 to 15),
                                           uptrr);
  wuptrs : mux2 generic map (16) port map (uop(2), instx&insty, uptrr, uptrs);
  wuptr0 : mux2 generic map (16) port map (iporp, uptri, uptrs, uptr0);
  couptr : adder_1 generic map (16) port map (uptr0, incamt, uptro, open);
  cofl : dmxn generic map (0, 8) port map (insty, dast, oflags);
  wry <= uop(0) and instx(5);
  rdbr <= (dbr xor insty(0)) and uop(0) and not uop(1) and uop(2) and anyx;
  l0 <= (uop(1) nor uop(2)) and insty(7);
  r0 <= uop(1) or uop(2) or insty(7);
  l1 <= (icj or not uop(1)) and insty(6);
  r1 <= (uop(1) and not icj) or insty(6);
  l2 <= (icj or (uop(1) nand uop(2))) and insty(5);
  r2 <= (uop(1) and uop(2) and not icj) or insty(5);
  setreg <= not uop(0) or (not uop(2) and (not uop(1)
            or ((instx(6) or instx(7)) and not instx(5))));
  icj <= uop(0) and uop(1) and uop(2) and instx(5);
  popstk <= iporp and uop(2) and not (instx(5) or instx(6) or instx(7));
  pshstk <= iporp and not uop(2);
  iporp <= uop(0) and uop(1);
  doow <= uop(2) and (instx(7) or not uop(0));
  doot <= uop(1) and (instx(6) or not uop(0));
  hix <= (others => instx(0));
  dast <= uop(0) and (uop(1) nor anyx) and uop(2);
end;

component mmix_cpu_core
  port (code : in ucode;
        iflags : in bit_vector (0 to 127);
        uregs : in ureg;
        uptri, nstk : in bit_vector (0 to 15);
        oregs : out bit_vector (0 to 63);
        wtb, oflags : out bit_vector (0 to 255);
        pshstk, popstk : out bit;
        uptro : out bit_vector (0 to 15));
end;

-- Interesting note:
-- Draw a cube of the instructions.
--
--  SET---------BIF
--   |\         /|
--   | \       / |
--   | MVB---MVW |
--   |  |     |  |
--   |  |     |  |
--   | MVT---MVO |
--   | /       \ |
--   |/         \|
--  PGO---------POP
--
-- The symmetries of this cube could be used to permute the opcodes
-- without increasing the complexity of the wiring.
-- The only other change that could be done is to swap PGO with BIF.
-- Obviously, it's best that the MV*s form a plane.
-- But that SET sits above MVB and POP (or rather CL*) sits above MVO
-- simplifies the code markedly.

entity mmix_microcode is
  port (code : out ucode);
end;

component mmix_microcode
  port (code : out ucode);
end;

entity mmix_full_cpu is
  generic (stkdpth, fremstg, memto, memfr, llocs : integer);
  port (lpio, hpio : in bit_vector (0 to 23);
        macherr : in bit_vector (0 to 7);
        clock : in bit;
        frmem : in bit_vector (0 to memfr-1);
        tomem : out bit_vector (0 to memto-1);
        sleep : out bit);
end;

architecture a1 of mmix_full_cpu is
  signal code : ucode;
  signal iflags : bit_vector (0 to 127);
  signal uregs : ureg;
  signal uptrb, nstkb, uptra : bit_vector (0 to 15);
  signal wrts, oflags : bit_vector (0 to 255);
  signal oregs, memmdro, rm, rd, re, rh, rr, rf, rv : bit_vector (0 to 63);
  signal push, pop, wrmdr, atcw, memerr, parerr, nomem : bit;
  signal itco, dtco, tco : bit_vector (0 to 37);
  signal rab, raa : bit_vector (0 to 31);
begin
  microcode : mmix_microcode port map (code);
  core : mmix_cpu_core port map (code, iflags, uregs, uptrb, nstkb,
                                 oregs, wrts, oflags, push, pop, uptra);
  stack : mcstack generic map (stkdpth) port map (uptra, push, pop, clock,
                                                  uptrb, nstkb);
  mstregs: for i in 1 to 31 generate
  begin
    reglr: if i < 3 or i > 19 or i = 6 or i = 7
             or i = 13 or i = 14 or i = 9 generate
      signal dat : bit_vector (0 to 64);
      signal wr : bit_vector (0 to 7);
    begin
      vrglr: if i /= 7 generate
      begin
        dat <= oregs;
        wr <= wrts(i*8 to i*8+7);
      end;
      mdr: if i = 7 generate
      begin
        whdr : mux2 generic map (72) port map (wrmdr, wrts(56 to 63)&oregs,
                                               h"FF"&memmdro, wr&dat);
      end;
      oreg : da_reg generic map (3, 6) port map (wr, clock, dat, uregs(i));
    end;
  end;
  alusrs : da_reg generic map (1, 4) port map (wrts(0 to 1), clock,
                                               oregs(0 to 15),
                                               uregs(0)(0 to 15));
  ptmn : da_reg generic map (1, 4) port map (wrts(68 to 69), clock,
                                             oregs(32 to 47),
                                             uregs(8)(32 to 47));
  treg1 : da_reg generic map (2, 5) port map (wrts(4 to 7), clock,
                                              oregs(32 to 63),
                                              uregs(0)(32 to 63));
  wreg22 : da_reg generic map (1, 4) port map (wrts(68 to 69), clock,
                                               oregs(32 to 47),
                                               uregs(8)(32 to 47));
  breg60 : da_reg generic map (0, 3) port map (wrts(96), clock,
                                               oregs(0 to 7),
                                               uregs(12)(0 to 7));
  afu : mmix_afu generic map (fremstg) port map (uregs(1), uregs(2),
                                                 rm, rd, re, rab,
                                                 uregs(0)(0 to 7),
                                                 uregs(12)(0 to 7),
                                                 uregs(3),
                                                 rh, rr, raa,
                                                 iflags(0), iflags(1),
                                                 iflags(2), iflags(4),
                                                 iflags(3),
                                                 uregs(12)(8 to 11));
  mmix_spregs : sregs port map (oregs, rf, rh, lpio&oflags(0 to 7)&hpio&
                                macherr(0)&oflags(30)&macherr(2 to 4)&nomem&
                                parerr&macherr(7), rr, raa,
                                uregs(0)(8 to 15), wrts(32 to 39),
                                wrts(136 to 143), wrts(120 to 127),
                                wrts(128 to 135), wrts(144 to 151),
                                oflags(33), memerr, wrts(2), oflags(32),
                                wrts(3), oflags(31), clock,
                                uregs(4), rd, re, uregs(17), rm,
                                uregs(15), uregs(16), uregs(18), rv,
                                rab, uregs(0)(16 to 23), uregs(0)(24 to 31),
                                iflags(24 to 31), iflags(5));
  akpb : or_comb generic map (8) port map (iflags(24 to 31), iflags(11));
  mmix_gpregs : gregs generic map (llocs)
    port map (uregs(16), uregs(15), oregs,
              uregs(0)(16 to 23), uregs(0)(24 to 31), uregs(9)(0 to 7),
              wrts(40 to 47), wrts(152 to 159), clock,
              uregs(5), uregs(19));
  itc : vtcache port map (uregs(13), uregs(12)(26 to 63),
                          oflags(24), oflags(25), oflags(29), clock,
                          itco, iflags(6));
  dtc : vtcache port map (uregs(13), uregs(12)(26 to 63),
                          oflags(27), oflags(28), oflags(29), clock,
                          dtco, iflags(7));
  wtc : mux2 generic map (38) port map (oflags(26), itco, dtco, tco);
  tcdr : da5by port map (wrts(99 to 103), oregs(24 to 63), tco, atcw, clock,
                         uregs(12)(24 to 63));
  b1024h : base1024 port map (uregs(9)(8 to 63), uregs(10)(0 to 15),
                              uregs(10)(16 to 31), uregs(10)(32 to 47),
                              uregs(10)(48 to 63), uregs(11)(0 to 15));
  decv : rvdec port map (rv, uregs(8)(0 to 7), uregs(8)(8 to 15),
                         uregs(8)(16 to 23), uregs(8)(24 to 31),
                         uregs(12)(16 to 23), uregs(11)(16 to 31),
                         uregs(11)(32 to 63));
  decpt : pthr port map (uregs(8)(32 to 47), uregs(8)(48 to 63),
                         iflags(8 to 10));
  cache : memcache generic map (memto, memfr) port map (uregs(6), uregs(7),
                                                        oflags(9), oflags(36),
                                                        oflags(37), oflags(38),
                                                        oflags(8),
                                                        oflags(34), oflags(10),
                                                        oflags(11), oflags(12),
                                                        oflags(13), oflags(14),
                                                        oflags(15), oflags(16)
                                                        oflags(18), oflags(19),
                                                        oflags(20), oflags(21),
                                                        oflags(22), oflags(35),
                                                        clock, memmdro, rf,
                                                        parerr, nomem,
                                                        iflags(12), wrmdr,
                                                        frmem, tomem);
  iflags(13 to 15) <= o"0";
  iflags(16 to 23) <= uregs(31)(56 to 63);
  iflags(24 to 127) <= (others => '0');
  sleep <= oflags(17);
  uregs(12)(12 to 15) <= h"0";
  atcw <= oflags(25) or oflags(26);
end;

component mmix_full_cpu
  generic (stkdpth, fremstg, memto, memfr, llocs : integer);
  port (lpio, hpio : in bit_vector (0 to 23);
        macherr : in bit_vector (0 to 7);
        clock : in bit;
        frmem : in bit_vector (0 to memfr-1);
        tomem : out bit_vector (0 to memto-1);
        sleep : out bit);
end;
