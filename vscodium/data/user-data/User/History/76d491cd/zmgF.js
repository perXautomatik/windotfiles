const skillsFileName = "global\\excel\\skills.txt";
const skills = D2RMM.readTsv(skillsFileName);
const pettypeFileName = "global\\excel\\pettype.txt";
const pets = D2RMM.readTsv(pettypeFileName);
const skeletalMageVFXFileDir = "hd\\character\\enemy\\necromage.json";
const mageVFX = D2RMM.readJson(skeletalMageVFXFileDir);

const golems = ["Clay Golem", "BloodGolem", "IronGolem", "FireGolem"];

const claygolem = {
  "pet type": "claygolem",
  group: "",
  basemax: 0,
  warp: 1,
  range: "",
  partysend: 1,
  unsummon: 1,
  automap: 1,
  name: "StrUI0",
  drawhp: 1,
  icontype: 3,
  baseicon: "earthgolumicon",
  mclass1: 289,
  micon1: "earthgolumicon",
  mclass2: "",
  micon2: "",
  mclass3: "",
  micon3: "",
  mclass4: "",
  micon4: "",
};
const bloodgolem = {
  "pet type": "bloodgolem",
  group: "",
  basemax: 0,
  warp: 1,
  range: "",
  partysend: 1,
  unsummon: 1,
  automap: 1,
  name: "StrUI0",
  drawhp: 1,
  icontype: 3,
  baseicon: "bloodgolumicon",
  mclass1: 290,
  micon1: "bloodgolumicon",
  mclass2: "",
  micon2: "",
  mclass3: "",
  micon3: "",
  mclass4: "",
  micon4: "",
};
const irongolem = {
  "pet type": "irongolem",
  group: "",
  basemax: 0,
  warp: 1,
  range: "",
  partysend: 1,
  unsummon: 1,
  automap: 1,
  name: "StrUI0",
  drawhp: 1,
  icontype: 3,
  baseicon: "metalgolumicon",
  mclass1: 291,
  micon1: "metalgolumicon",
  mclass2: "",
  micon2: "",
  mclass3: "",
  micon3: "",
  mclass4: "",
  micon4: "",
};
const firegolem = {
  "pet type": "firegolem",
  group: "",
  basemax: 0,
  warp: 1,
  range: "",
  partysend: 1,
  unsummon: 1,
  automap: 1,
  name: "StrUI0",
  drawhp: 1,
  icontype: 3,
  baseicon: "firegolumicon",
  mclass1: 292,
  micon1: "firegolumicon",
  mclass2: "",
  micon2: "",
  mclass3: "",
  micon3: "",
  mclass4: "",
  micon4: "",
};
let propArr = [
  "srvstfunc",
  "srvdofunc",
  "srvstopfunc",
  "prgstack",
  "srvprgfunc1",
  "srvprgfunc2",
  "srvprgfunc3",
  "prgcalc1",
  "prgcalc2",
  "prgcalc3",
  "prgdam",
  "srvmissile",
  "decquant",
  "lob",
  "srvmissilea",
  "srvmissileb",
  "srvmissilec",
  "useServerMissilesOnRemoteClients",
  "srvoverlay",
  "aurafilter",
  "aurastate",
  "auratargetstate",
  "auralencalc",
  "aurarangecalc",
  "aurastat1",
  "aurastatcalc1",
  "aurastat2",
  "aurastatcalc2",
  "aurastat3",
  "aurastatcalc3",
  "aurastat4",
  "aurastatcalc4",
  "aurastat5",
  "aurastatcalc5",
  "aurastat6",
  "aurastatcalc6",
  "auraevent1",
  "auraeventfunc1",
  "auraevent2",
  "auraeventfunc2",
  "auraevent3",
  "auraeventfunc3",
  "passivestate",
  "passiveitype",
  "passivereqweaponcount",
  "passivestat1",
  "passivecalc1",
  "passivestat2",
  "passivecalc2",
  "passivestat3",
  "passivecalc3",
  "passivestat4",
  "passivecalc4",
  "passivestat5",
  "passivecalc5",
  "passivestat6",
  "passivecalc6",
  "passivestat7",
  "passivecalc7",
  "passivestat8",
  "passivecalc8",
  "passivestat9",
  "passivecalc9",
  "passivestat10",
  "passivecalc10",
  "passivestat11",
  "passivecalc11",
  "passivestat12",
  "passivecalc12",
  "passivestat13",
  "passivecalc13",
  "passivestat14",
  "passivecalc14",
  "summon",
  "pettype",
  "petmax",
  "summode",
  "sumskill1",
  "sumsk1calc",
  "sumskill2",
  "sumsk2calc",
  "sumskill3",
  "sumsk3calc",
  "sumskill4",
  "sumsk4calc",
  "sumskill5",
  "sumsk5calc",
  "sumumod",
  "sumoverlay",
  "stsuccessonly",
  "stsound",
  "stsoundclass",
  "stsounddelay",
  "weaponsnd",
  "dosound",
  "dosound a",
  "dosound b",
  "tgtoverlay",
  "tgtsound",
  "prgoverlay",
  "prgsound",
  "castoverlay",
  "cltoverlaya",
  "cltoverlayb",
  "cltstfunc",
  "cltdofunc",
  "cltstopfunc",
  "cltprgfunc1",
  "cltprgfunc2",
  "cltprgfunc3",
  "cltmissile",
  "cltmissilea",
  "cltmissileb",
  "cltmissilec",
  "cltmissiled",
  "cltcalc1",
  "*cltcalc1 desc",
  "cltcalc2",
  "*cltcalc2 desc",
  "cltcalc3",
  "*cltcalc3 desc",
  "warp",
  "immediate",
  "enhanceable",
  "attackrank",
  "noammo",
  "range",
  "weapsel",
  "itypea1",
  "itypea2",
  "itypea3",
  "etypea1",
  "etypea2",
  "itypeb1",
  "itypeb2",
  "itypeb3",
  "etypeb1",
  "etypeb2",
  "anim",
  "seqtrans",
  "monanim",
  "seqnum",
  "seqinput",
  "durability",
  "UseAttackRate",
  "LineOfSight",
  "TargetableOnly",
  "SearchEnemyXY",
  "SearchEnemyNear",
  "SearchOpenXY",
  "SelectProc",
  "TargetCorpse",
  "TargetPet",
  "TargetAlly",
  "TargetItem",
  "AttackNoMana",
  "TgtPlaceCheck",
  "KeepCursorStateOnKill",
  "ContinueCastUnselected",
  "ClearSelectedOnHold",
  "ItemEffect",
  "ItemCltEffect",
  "ItemTgtDo",
  "ItemTarget",
  "ItemUseRestrict",
  "ItemCheckStart",
  "ItemCltCheckStart",
  "ItemCastSound",
  "ItemCastOverlay",
  "skpoints",
  "reqlevel",
  "maxlvl",
  "reqstr",
  "reqdex",
  "reqint",
  "reqvit",
  "reqskill1",
  "reqskill2",
  "reqskill3",
  "restrict",
  "State1",
  "State2",
  "State3",
  "localdelay",
  "globaldelay",
  "leftskill",
  "rightskill",
  "repeat",
  "alwayshit",
  "usemanaondo",
  "startmana",
  "minmana",
  "manashift",
  "mana",
  "lvlmana",
  "interrupt",
  "InTown",
  "aura",
  "periodic",
  "perdelay",
  "finishing",
  "prgchargestocast",
  "prgchargesconsumed",
  "passive",
  "progressive",
  "scroll",
  "calc1",
  "*calc1 desc",
  "calc2",
  "*calc2 desc",
  "calc3",
  "*calc3 desc",
  "calc4",
  "*calc4 desc",
  "calc5",
  "*calc5 desc",
  "calc6",
  "*calc6 desc",
  "Param1",
  "*Param1 Description",
  "Param2",
  "*Param2 Description",
  "Param3",
  "*Param3 Description",
  "Param4",
  "*Param4 Description",
  "Param5",
  "*Param5 Description",
  "Param6",
  "*Param6 Description",
  "Param7",
  "*Param7 Description",
  "Param8",
  "*Param8 Description",
  "Param9",
  "*Param9 Description",
  "Param10",
  "*Param10 Description2",
  "Param11",
  "*Param11 Description",
  "Param12",
  "*Param12 Description",
  "InGame",
  "ToHit",
  "LevToHit",
  "ToHitCalc",
  "ResultFlags",
  "HitFlags",
  "HitClass",
  "Kick",
  "HitShift",
  "SrcDam",
  "MinDam",
  "MinLevDam1",
  "MinLevDam2",
  "MinLevDam3",
  "MinLevDam4",
  "MinLevDam5",
  "MaxDam",
  "MaxLevDam1",
  "MaxLevDam2",
  "MaxLevDam3",
  "MaxLevDam4",
  "MaxLevDam5",
  "DmgSymPerCalc",
  "EType",
  "EMin",
  "EMinLev1",
  "EMinLev2",
  "EMinLev3",
  "EMinLev4",
  "EMinLev5",
  "EMax",
  "EMaxLev1",
  "EMaxLev2",
  "EMaxLev3",
  "EMaxLev4",
  "EMaxLev5",
  "EDmgSymPerCalc",
  "ELen",
  "ELevLen1",
  "ELevLen2",
  "ELevLen3",
  "ELenSymPerCalc",
  "aitype",
  "aibonus",
  "cost mult",
  "cost add",
  "*eol",
];
//let skllvlReq = 1; 
const configSkill = config.necromageSkill;
const desireskill = skills.rows.find((obj) => obj.skill === configSkill);
const fireBallSkill = skills.rows.find((obj) => obj.skill === "Fire Ball");
const raiseSkeletalMageSkill = skills.rows.find(
  (obj) => obj.skill === "Raise Skeletal Mage"
);

function updateValue(obj) {
  for (const key in obj) {
    if (typeof obj[key] === "object" && obj[key] !== null) {
      updateValue(obj[key]); // Recursive call for nested objects
    } else if (
      typeof obj[key] === "string" &&
      obj[key].startsWith("data/hd/vfx/particles/character/enemy/")
    ) {
      if (
        (desireskill.srvmissile.includes("poison") ||
          desireskill.srvmissile.includes("plague")) &&
        desireskill.charclass !== ""
      ) {
        obj[key] =
          "data/hd/vfx/particles/character/enemy/skmage_pois1/vfx_skmage_pois1_wrist.particles";
      }
      if (
        (desireskill.srvmissile.includes("fire") ||
          desireskill.skill.includes("Meteor") ||
          desireskill.skill.includes("Blaze") ||
          desireskill.skill.includes("Hydra") ||
          desireskill.skill.includes("Fire Wall")) &&
        desireskill.charclass !== ""
      ) {
        obj[key] =
          "data/hd/vfx/particles/character/enemy/skmage_fire1/vfx_skmage_fire1_wrist.particles";
      }
      if (
        (desireskill.srvmissile.includes("cold") ||
          desireskill.srvmissile.includes("frozen") ||
          desireskill.srvmissile.includes("freezing") ||
          desireskill.srvmissile.includes("ice") ||
          desireskill.srvmissile.includes("glacial") ||
          desireskill.skill.includes("Blizzard")) &&
        desireskill.charclass !== ""
      ) {
        obj[key] =
          "data/hd/vfx/particles/character/enemy/skmage_cold1/vfx_skmage_cold1_wrist.particles";
      }
      if (
        (desireskill.srvmissile.includes("light") ||
          desireskill.srvmissile.includes("holy")) &&
        desireskill.charclass !== ""
      ) {
        obj[key] =
          "data/hd/vfx/particles/character/enemy/skmage_ltng1/vfx_skmage_ltng_wrist.particles";
      }
    }
  }
}
updateValue(mageVFX);


skills.rows.forEach((row) => {
  if (row.maxlvl !== "") {
    row.maxlvl = config.maxlvl;
  }
  if (row.reqskill1 !== "" || row.reqskill2 !== "" || row.reqlevel !== "") {
    row.reqskill1 = "";
    row.reqskill2 = "";
    row.reqlevel = skllvlReq;
  }
  // if (row.charclass !== "") {
  //   row.reqlevel = config.reqlevel;
  // }
  if (row.srvdofunc == 56 && golems.includes(row.skill)) {
    row.petmax = config.golems;
  }
  if (row.skill === "Amplify Damage") {
    row.aurastat1 = -config.aurastat1;
  }
  if (row.skill === "Lower Resist") {
    for (i = 1; i <= 4; i++) {
      row[`aurastatcalc${i}`] = `-(${row.Param5} + ${row.Param1}/2)`;
    }
  }
  if (row.skill === "Raise Skeleton") {
    // row.petmax = "min(lvl,5)";
    if (config.aura) {
      row.sumskill1 = "Concentration";
      row.sumsk1calc = "(lvl < 5)?0:min(lvl,12)";
    }
  }
  if (row.skill === "Raise Skeletal Mage") {
    // row.petmax = "min(lvl,5)";
    if (config.aura) {
      row.sumskill1 = "Meditation";
      row.sumsk1calc = "(lvl < 5)?0:min(lvl,12)";
    }
  }
  if (row.skill === "Clay Golem") {
    row.pettype = "claygolem";
    if (config.aura) {
      row.sumskill1 = "Conviction";
      row.sumsk1calc = "(lvl < 20)?0:min(lvl,12)";
    }
  }
  if (row.skill === "BloodGolem") {
    row.pettype = "bloodgolem";
    if (config.aura) {
      row.sumskill1 = "Vigor";
      row.sumsk1calc = "(lvl < 5)?0:min(lvl,12)";
    }
  }
  if (row.skill === "IronGolem") row.pettype = "irongolem";
  if (row.skill === "FireGolem") row.pettype = "firegolem";

  if (
    config.ToggleSkeletalMageSkillChange &&
    row.skill === "NecromageMissile"
  ) {
    for (i = 0; i < propArr.length; i++) {
      row[`${propArr[i]}`] = desireskill[`${propArr[i]}`];
    }
  }
  if (
    config.ToggleSkeletalMageSkillChange &&
    row.skill === "HydraMissile" &&
    configSkill === "Hydra"
  ) {
    for (i = 0; i < propArr.length; i++) {
      row[`${propArr[i]}`] = fireBallSkill[`${propArr[i]}`];
    }
    // raiseSkeletalMageSkill.petmax = 1;
  }
});
pets.rows.push(bloodgolem, irongolem, firegolem);
pets.rows.forEach((row) => {
  if (row[`pet type`] == "golem") {
    row[`pet type`] = "claygolem";
    if (row.baseicon !== "") row.baseicon = "earthgolumicon";
    if (row.mclass1 !== "") row.mclass1 = 289;
    if (row.micon1 !== "") row.micon1 = "earthgolumicon";
    if (row.mclass2 !== "") row.mclass2 = "";
    if (row.micon2 !== "") row.micon2 = "";
    if (row.mclass3 !== "") row.mclass3 = "";
    if (row.micon3 !== "") row.micon3 = "";
    if (row.mclass4 !== "") row.mclass4 = "";
    if (row.micon4 !== "") row.micon4 = "";
  }
});

// const profileHD = D2RMM.readJson("global\\ui\\layouts\\_profilehd.json");
// profileHD.FontColorRed = { r: 0, b: 255, g: 255, a: 255 };
// D2RMM.writeJson("global\\ui\\layouts\\_profilehd.json", profileHD);
// updateValue(mageVFX);
D2RMM.writeTsv(skillsFileName, skills);
D2RMM.writeTsv(pettypeFileName, pets);
D2RMM.writeJson(skeletalMageVFXFileDir, mageVFX);
