-- stv: store value to key
-- stm: store mode of key given to its value, or delete if mode is 0
-- clr: clear entire cache
-- ck: cache contains key; if this is not set, valo is nonsense.
entity vtcache is
  port (key : in bit_vector (0 to 63);
        vali : in bit_vector (0 to 37);
        stv, stm, clr, clock : in bit;
        valo : out bit_vector (0 to 37);
        ck : out bit);
end;

component vtcache
  port (key : in bit_vector (0 to 63);
        vali : in bit_vector (0 to 39);
        stv, stm, clr, clock : in bit;
        valo : out bit_vector (0 to 39);
        ck : out bit);
end;

-- memto: how many bits do we send to the memory?
-- memfr: how many bits does the memory send us?
-- wrt: write
-- rd: read
-- cdbk: clear data cache block containing MAR (i.e., set it up to be
-- next to forget)
-- pldd: preload data cache blocks containing any locations between MDR and MAR
-- pldi: same except instruction cache
-- delbt: delete data cache blocks containing
-- only locations between MDR and MAR, write dirty ones
-- lock: lock memory location MAR, and bypass cache
-- unlock: release hold, stop bypassing cache
-- clnd: Write all dirty blocks in data cache
-- deld: Delete data cache. Do not write.
-- clnbt: Write dirty blocks containing any locations between MDR and MAR
-- delba: As delbt, except change only to any.
-- clri: As delbt, but instruction cache
-- deli: As deld, but instruction cache
-- floc: Memory failure location (nonsense unless parerr or nomem set)
-- parerr: Parity error; floc set to location thereof.
-- nomem: Missing memory; floc set to location thereof if no parity error.
-- busy: Either writing dirty cache blocks to core or reading or writing
-- while locked.
-- wtmdr: Write to the memory data register.

entity memcache is
  generic (memto, memfr : integer);
  port (mar, mdri : in bit_vector (0 to 63);
        wrt, rd, cdbk, pldd, pldi, delbt, lock, unlock : in bit;
        clnd, deld, clnbt, delba, clri, deli, clock : in bit;
        mdro, floc : out bit_vector (0 to 63);
        parerr, nomem, busy, wtmdr : out bit,
        frmem : in bit_vector (0 to memto-1);
        tomem : out bit_vector (0 to memfr-1));
end;

component memcache
  generic (memto, memfr : integer);
  port (mar, mdri : in bit_vector (0 to 63);
        wrt, rd, cdbk, pldd, pldi, delbt, lock, unlock : in bit;
        clnd, deld, clnbt, delba, clri, deli, clock : in bit;
        mdro, floc : out bit_vector (0 to 63);
        parerr, nomem, busy : out bit,
        frmem : in bit_vector (0 to memto-1);
        tomem : out bit_vector (0 to memfr-1));
end;
