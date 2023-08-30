// skills.txt
const skillsFilename = 'global\\excel\\skills.txt';
const skills = D2RMM.readTsv(skillsFilename);

skills.rows.forEach((row) => {

  // #1 Bone Spear
  // calc1 = Number of missiles created - keep for base level if needed
// row["calc1"] = "((skill('Bone Spear'.blvl) < 10) ? 0 : ((skill('Bone Spear'.blvl) < 20) ? 2 : 3 ))";
// calc1 = Number of missiles created
// Needed for the number of missiles skill description
// Synergy Bonus

  if (config.bone_spear) {
    if (row["skill"] === "Bone Spear") { row["srvdofunc"] = 8; row["cltdofunc"] = 17; row["srvmissilea"] = "bonespear"; row["cltmissilea"] = "bonespear"; row["cltmissileb"] = "bonespear"; row["calc1"] = "(skill('Bone Spear'.lvl) / 10) + 1"; row["calc6"] = "skill('Bone Spear'.lvl) - skill('Bone Spear'.blvl)"; row["Param8"] = 11; row["EDmgSymPerCalc"] = "(skill('Teeth'.blvl)+skill('Bone Spirit'.blvl)+skill('Weaken'.blvl))*par8"; }
    if (row["skill"] === "Bone Spirit") { row["Param8"] = 11; row["EDmgSymPerCalc"] = "(skill('Teeth'.blvl)+skill('Bone Spirit'.blvl)+skill('Weaken'.blvl))*par8"; }
    if (row["skill"] === "Teeth") { row["Param8"] = 20; row["EDmgSymPerCalc"] = "skill('Bone Spear'.blvl) + skill('Bone Spirit'.blvl)+skill('Weaken'.blvl))*par8"; }
  }

  // #2 Weaken
  if (config.weaken) { if (row["skill"] === "Weaken") { row["aurastat2"] = "magicresist"; row["aurastatcalc2"] = "-(par7 + (lvl - 1) * 1)"; row["Param7"] = 5; row["*Param7 Description"] = "Enemy Magic Damage Reduce Baseline"; row["Param8"] = 1; row["*Param8 Description"] = "Enemy Magic Damage Reduce Per level"; } }

  // #region poison explosion
  // #3 poison explosion -> New SKill: Posion Freak
  if (config.poison_dagger) {
    if (row["skill"] == "poison explosion") {
      row['skill'] = 'poison explosion', row['*Id'] = 73, row['charclass'] = 'nec', row['skilldesc'] = 'poison explosion', row['srvstfunc'] = '', row['srvdofunc'] = 68, row['srvstopfunc'] = '', row['prgstack'] = '', row['srvprgfunc1'] = '', row['srvprgfunc2'] = '', row['srvprgfunc3'] = '', row['prgcalc1'] = '', row['prgcalc2'] = '', row['prgcalc3'] = '', row['prgdam'] = '', row['srvmissile'] = '', row['decquant'] = '', row['lob'] = '', row['srvmissilea'] = 'battleorders', row['srvmissileb'] = '', row['srvmissilec'] = '', row['useServerMissilesOnRemoteClients'] = '', row['srvoverlay'] = '', row['aurafilter'] = '', row['aurastate'] = 'battleorders', row['auratargetstate'] = 'battleorders', row['auralencalc'] = 15000, row['aurarangecalc'] = '', row['aurastat1'] = 'poisonmindam', row['aurastatcalc1'] = 'enma', row['aurastat2'] = 'poisonmaxdam', row['aurastatcalc2'] = 'exma', row['aurastat3'] = 'item_tohit_percent', row['aurastatcalc3'] = 'toht', row['aurastat4'] = 'poisonlength', row['aurastatcalc4'] = 'edma', row['aurastat5'] = 'passive_pois_pierce', row['aurastatcalc5'] = 'ln34', row['aurastat6'] = '', row['aurastatcalc6'] = '', row['auraevent1'] = '', row['auraeventfunc1'] = '', row['auraevent2'] = '', row['auraeventfunc2'] = '', row['auraevent3'] = '', row['auraeventfunc3'] = '', row['passivestate'] = '', row['passiveitype'] = '', row['passivereqweaponcount'] = '', row['passivestat1'] = '', row['passivecalc1'] = '', row['passivestat2'] = '', row['passivecalc2'] = '', row['passivestat3'] = '', row['passivecalc3'] = '', row['passivestat4'] = '', row['passivecalc4'] = '', row['passivestat5'] = '', row['passivecalc5'] = '', row['passivestat6'] = '', row['passivecalc6'] = '', row['passivestat7'] = '', row['passivecalc7'] = '', row['passivestat8'] = '', row['passivecalc8'] = '', row['passivestat9'] = '', row['passivecalc9'] = '', row['passivestat10'] = '', row['passivecalc10'] = '', row['summon'] = '', row['pettype'] = '', row['petmax'] = '', row['summode'] = '', row['sumskill1'] = '', row['sumsk1calc'] = '', row['sumskill2'] = '', row['sumsk2calc'] = '', row['sumskill3'] = '', row['sumsk3calc'] = '', row['sumskill4'] = '', row['sumsk4calc'] = '', row['sumskill5'] = '', row['sumsk5calc'] = '', row['sumumod'] = '', row['sumoverlay'] = '', row['stsuccessonly'] = '', row['stsound'] = '', row['stsoundclass'] = 'necromancer_poison_cast_hd', row['stsounddelay'] = '', row['weaponsnd'] = '', row['dosound'] = '', row['dosound a'] = '', row['dosound b'] = '', row['tgtoverlay'] = '', row['tgtsound'] = '', row['prgoverlay'] = '', row['prgsound'] = '', row['castoverlay'] = '', row['cltoverlaya'] = '', row['cltoverlayb'] = '', row['cltstfunc'] = '', row['cltdofunc'] = 25, row['cltstopfunc'] = '', row['cltprgfunc1'] = '', row['cltprgfunc2'] = '', row['cltprgfunc3'] = '', row['cltmissile'] = '', row['cltmissilea'] = 'battleorders', row['cltmissileb'] = '', row['cltmissilec'] = '', row['cltmissiled'] = '', row['cltcalc1'] = 0, row['*cltcalc1 desc'] = 'Missile Velocity Adder', row['cltcalc2'] = '', row['*cltcalc2 desc'] = '', row['cltcalc3'] = '', row['*cltcalc3 desc'] = '', row['warp'] = '', row['immediate'] = '', row['enhanceable'] = 1, row['attackrank'] = 9, row['noammo'] = '', row['range'] = 'none', row['weapsel'] = '', row['itypea1'] = '', row['itypea2'] = '', row['itypea3'] = '', row['etypea1'] = '', row['etypea2'] = '', row['itypeb1'] = '', row['itypeb2'] = '', row['itypeb3'] = '', row['etypeb1'] = '', row['etypeb2'] = '', row['anim'] = 'SC', row['seqtrans'] = 'SC', row['monanim'] = 'xx', row['seqnum'] = '', row['seqinput'] = '', row['durability'] = '', row['UseAttackRate'] = 1, row['LineOfSight'] = '', row['TargetableOnly'] = '', row['SearchEnemyXY'] = '', row['SearchEnemyNear'] = '', row['SearchOpenXY'] = '', row['SelectProc'] = '', row['TargetCorpse'] = '', row['TargetPet'] = '', row['TargetAlly'] = '', row['TargetItem'] = '', row['AttackNoMana'] = '', row['TgtPlaceCheck'] = '', row['KeepCursorStateOnKill'] = '', row['ContinueCastUnselected'] = '', row['ClearSelectedOnHold'] = '', row['ItemEffect'] = '', row['ItemCltEffect'] = '', row['ItemTgtDo'] = '', row['ItemTarget'] = '', row['ItemCheckStart'] = '', row['ItemCltCheckStart'] = '', row['ItemCastSound'] = '', row['ItemCastOverlay'] = '', row['skpoints'] = '', row['reqlevel'] = 6, row['maxlvl'] = 20, row['reqstr'] = '', row['reqdex'] = '', row['reqint'] = '', row['reqvit'] = '', row['reqskill1'] = '', row['reqskill2'] = '', row['reqskill3'] = '', row['restrict'] = '', row['State1'] = '', row['State2'] = '', row['State3'] = '', row['localdelay'] = '', row['globaldelay'] = '', row['leftskill'] = 0, row['rightskill'] = 1, row['repeat'] = '', row['alwayshit'] = '', row['usemanaondo'] = '', row['startmana'] = '', row['minmana'] = 1, row['manashift'] = 8, row['mana'] = 7, row['lvlmana'] = 0, row['interrupt'] = 1, row['InTown'] = 1, row['aura'] = '', row['periodic'] = '', row['perdelay'] = '', row['finishing'] = '', row['prgchargestocast'] = '', row['prgchargesconsumed'] = '', row['passive'] = '', row['progressive'] = '', row['scroll'] = '', row['calc1'] = '', row['*calc1 desc'] = '', row['calc2'] = '', row['*calc2 desc'] = '', row['calc3'] = '', row['*calc3 desc'] = '', row['calc4'] = '', row['*calc4 desc'] = '', row['calc5'] = '', row['*calc5 desc'] = '', row['calc6'] = '', row['*calc6 desc'] = '', row['Param1'] = 750, row['*Param1 Description'] = 'Duration baseline', row['Param2'] = 250, row['*Param2 Description'] = 'Duration per level', row['Param3'] = 5, row['*Param3 Description'] = 'Poison Resistance reduction baseline', row['Param4'] = 1, row['*Param4 Description'] = 'Poison Resistance reduction per level', row['Param5'] = '', row['*Param5 Description'] = '', row['Param6'] = '', row['*Param6 Description'] = '', row['Param7'] = '', row['*Param7 Description'] = '', row['Param8'] = 125, row['*Param8 Description'] = 'Duration synergy', row['Param9'] = '', row['*Param9 Description'] = '', row['Param10'] = '', row['*Param10 Description2'] = '', row['Param11'] = '', row['*Param11 Description'] = '', row['Param12'] = '', row['*Param12 Description'] = '', row['InGame'] = 1, row['ToHit'] = 50, row['LevToHit'] = 10, row['ToHitCalc'] = '', row['ResultFlags'] = '', row['HitFlags'] = '', row['HitClass'] = '', row['Kick'] = '', row['HitShift'] = 8, row['SrcDam'] = 128, row['MinDam'] = '', row['MinLevDam1'] = '', row['MinLevDam2'] = '', row['MinLevDam3'] = '', row['MinLevDam4'] = '', row['MinLevDam5'] = '', row['MaxDam'] = '', row['MaxLevDam1'] = '', row['MaxLevDam2'] = '', row['MaxLevDam3'] = '', row['MaxLevDam4'] = '', row['MaxLevDam5'] = '', row['DmgSymPerCalc'] = '', row['EType'] = 'pois', row['EMin'] = 32, row['EMinLev1'] = 6, row['EMinLev2'] = 14, row['EMinLev3'] = 66, row['EMinLev4'] = 75, row['EMinLev5'] = 110, row['EMax'] = 40, row['EMaxLev1'] = 10, row['EMaxLev2'] = 18, row['EMaxLev3'] = 78, row['EMaxLev4'] = 85, row['EMaxLev5'] = 130, row['EDmgSymPerCalc'] = "(skill('poison explosion'.blvl))*10", row['ELen'] = 50, row['ELevLen1'] = 0, row['ELevLen2'] = 0, row['ELevLen3'] = 0, row['ELenSymPerCalc'] = '', row['aitype'] = '', row['aibonus'] = '', row['cost mult'] = 768, row['cost add'] = 32000, row['*eol\r'] = 0 }
  }
  // #endregion


  // #4 Raise Skeletal Mage
  // Add multishot
// HP per level
// Armor per level
// #5 Fire Golem - Modify aura with the newly added one (holy fire golem) and buff life + def, decrease mana cost
// Armor per level 
// #6 Blood Golem
// Oak Sage Aura
// armor buff
// #7 Curses
// #8 Golem Mastery buff
// HP % baseline
// HP % per level
  if (config.raise_skeletal_mage) { if (row["skill"] === "Raise Skeletal Mage") { row["sumumod"] = 29; row["petmax"] = "(lvl < 4) ?lvl:(2+lvl/4)"; row["Param2"] = 20; row["Param5"] = 20; } }
  if (config.fire_golem) { if (row["skill"] === "FireGolem") { row["sumskill1"] = "holy fire golem"; row["sumsk1calc"] = "ln56"; row["lvlmana"] = row["Param9"] = 35; row["*Param9 Description"] = "Armor per level"; row["passivecalc3"] = "lvl*par9"; } }
  if (config.blood_golem) { if (row["skill"] === "BloodGolem") { row["aurastat1"] = 'item_openwounds'; row["aurastatcalc1"] = 100; row["aurastat2"] = 'item_ignoretargetac'; row["aurastatcalc2"] = 1; row["sumskill1"] = "Blood Golem Oak Sage Aura"; row["sumsk1calc"] = "lvl"; row["Param9"] = 10; row["Param10"] = 2; row["Param11"] = 35; row["*Param11 Description"] = "Armor per level"; row["passivecalc4"] = "lvl*pa11"; } }
  if (config.no_curse_prereq) { if ( row["skill"] === "Dim Vision" || row["skill"] === "Weaken" || row["skill"] === "Iron Maiden" || row["skill"] === "Terror" || row["skill"] === "Confuse" || row["skill"] === "Life Tap" || row["skill"] === "Attract" || row["skill"] === "Decrepify" || row["skill"] === "Lower Resist" ) { row["reqskill1"] = ""; row["reqskill2"] = ""; row["reqlevel"] = 6; } }
  if (config.fire_golem) { if (row["skill"] === "Golem Mastery") { row["Param1"] = 50; row["Param2"] = 30; } }

});

let skillID = Math.max(...skills.rows.map((row) => row['*Id']));

// #5 Fire Golem - Add new Holy Fire aura for Golem
if (config.fire_golem) { var golemFireDamageMultiplier = 10; skills.rows.push( { 'skill': 'Holy Fire Golem', '*Id': (skillID = skillID + 1), 'charclass': '', 'skilldesc': 'holy fire golem', 'srvdofunc': 66, 'aurafilter': 42883, 'aurastate': 'holyfire', 'auratargetstate': 'conviction', 'aurarangecalc': 'ln12', 'aurastat1': 'fireresist', 'aurastatcalc1': "-ln34", 'aurastat2': 'coldresist', 'aurastatcalc2': "-ln34", 'aurastat3': 'lightresist', 'aurastatcalc3': "-ln34", 'passivestat1': 'firemindam', 'passivecalc1': 'enms*par5/256', 'passivestat2': 'firemaxdam', 'passivecalc2': 'exms*par5/256', 'enhanceable': 1, 'attackrank': 0, 'range': 'none', 'monanim': 'xx', 'reqlevel': 6, 'maxlvl': 20, 'reqskill1': '', 'leftskill': 0, 'rightskill': 1, 'minmana': 0, 'manashift': 8, 'mana': 0, 'lvlmana': 0, 'interrupt': 1, 'InTown': 1, 'aura': 1, 'perdelay': 50, 'Param1': 6, '*Param1 Description': 'Radius baseline', 'Param2': 1, '*Param2 Description': 'Radius per level', 'Param3': 10, '*Param3 Description': 'Resistance % reduction baseline', 'Param4': 2, '*Param4 Description': 'Resistance % reduction per level', 'Param5': 6, '*Param5 Description': 'Damage multiplier added to Attacks', 'Param6': 100, '*Param6 Description': 'Area Damage % Range Scaling (from 100% to 100+X% damage, based on how close the enemy position is to the caster)', 'Param7': 10, '*Param7 Description': 'Damage synergy', 'Param8': 21, '*Param8 Description': 'Damage synergy', 'InGame': 1, 'ResultFlags': 16385, 'HitShift': 7, 'EType': 'fire', 'EMin': 2 * golemFireDamageMultiplier, 'EMinLev1': 1 * golemFireDamageMultiplier, 'EMinLev2': 4 * golemFireDamageMultiplier, 'EMinLev3': 6 * golemFireDamageMultiplier, 'EMinLev4': 7 * golemFireDamageMultiplier, 'EMinLev5': 8 * golemFireDamageMultiplier, 'EMax': 6 * golemFireDamageMultiplier, 'EMaxLev1': 2 * golemFireDamageMultiplier, 'EMaxLev2': 5 * golemFireDamageMultiplier, 'EMaxLev3': 7 * golemFireDamageMultiplier, 'EMaxLev4': 8 * golemFireDamageMultiplier, 'EMaxLev5': 9 * golemFireDamageMultiplier, 'EDmgSymPerCalc': "", 'cost mult': 384, 'cost add': 3000, '*eol\r': 0 });}


// #6 Blood Golem - Add new Oak Sage and Oak Sage aura (a weaker Oak Sage)
if (config.blood_golem) {
  skills.rows.push({ 'skill': 'Blood Golem Oak Sage', '*Id': (skillID = skillID + 1), 'skilldesc': 'oak sage', 'srvdofunc': 119, 'passivestat1': 'poisonresist', 'passivecalc1': 100, 'passivestat2': 'maxpoisonresist', 'passivecalc2': 100, 'summon': 'oaksage', 'pettype': 'totem', 'petmax': 1, 'summode': 'NU', 'sumskill1': 'Blood Golem Oak Sage Aura', 'sumsk1calc': 'lvl', 'stsound': 'druid_summon', 'enhanceable': 1, 'attackrank': 0, 'range': 'none', 'anim': 'SC', 'seqtrans': 'SC', 'monanim': 'xx', 'UseAttackRate': 1, 'LineOfSight': 4, 'reqlevel': 6, 'maxlvl': 20, 'restrict': 1, 'leftskill': 0, 'rightskill': 1, 'minmana': 1, 'manashift': 8, 'mana': 15, 'lvlmana': 1, 'interrupt': 1, 'InTown': 1, 'calc1': '(lvl-1)*par3', '*calc1 desc': 'HP %', 'calc2': 'ulvl', '*calc2 desc': 'Summon Pet Level (Min=1)', 'Param1': 10, '*Param1 Description': 'Aura HP % baseline (must match Oak Sage Aura Param3)', 'Param2': 2, '*Param2 Description': 'Aura HP % per level (must match Oak Sage Aura Param4)', 'Param3': 30, '*Param3 Description': 'HP % per level', 'Param7': 30, '*Param7 Description': 'Radius baseline (must match Oak Sage Aura Param1)', 'Param8': 2, '*Param8 Description': 'Radius per level (must match Oak Sage Aura Param2)', 'InGame': 1, 'HitShift': 8, 'cost mult': 384, 'cost add': 3000, '*eol\r': 0 });
  skills.rows.push({ 'skill': 'Blood Golem Oak Sage Aura', '*Id': (skillID = skillID + 1),    'srvdofunc': 65, 'aurafilter': 65795, 'aurastate': 'oaksagecontrol', 'auratargetstate': 'oaksage', 'aurarangecalc': 'ln12', 'aurastat1': 'item_maxhp_percent', 'aurastatcalc1': 'ln34', 'enhanceable': 1, 'attackrank': 0, 'range': 'none', 'anim': 'SQ', 'seqtrans': 'SQ', 'monanim': 'A1', 'UseAttackRate': 1, 'reqlevel': 1, 'leftskill': 0, 'rightskill': 0, 'interrupt': 1, 'aura': 1, 'Param1': 30, '*Param1 Description': 'Radius baseline (must match Oak Sage Param7)', 'Param2': 2, '*Param2 Description': 'Radius per level (must match Oak Sage Param8)', 'Param3': 10, '*Param3 Description': 'HP % baseline (must match Oak Sage Param1)', 'Param4': 2, '*Param4 Description': 'HP % per level (must match Oak Sage Param2)', 'InGame': 1, 'HitShift': 8, 'cost add': 0, '*eol\r': 0 });
}

D2RMM.writeTsv(skillsFilename, skills);

// Modify Skill descriptions
// #1 Bone Spear description
// row["desccalca3"] = "(1+(lvl-1)*1 - skill('Bone Spear'.clc6)) / 10 + 1";
// #2 Weaken description
// #3 poison explosion -> New SKill: Posion Freak description
// #4 Raise Skeletal Mage
// #5 Fire Golem
// replace Holy Fire with Holy Fire Golem
// Remove Iron Golem Armor synergy text
// #6 Blood Golem
const skilldescFilename = 'global\\excel\\skilldesc.txt';
const skilldesc = D2RMM.readTsv(skilldescFilename);

skilldesc.rows.forEach((row) => {
  if (config.bone_spear) { if (row["skilldesc"] === "bone spear") { row["descline3"] = 74; row["desctexta3"] = "StrSkill80002"; row["desccalca3"] = "(skill('Bone Spear'.lvl) / 10) + 1"; row["dsc3textb3"] = "skillname72"; row["dsc3textb4"] = "skillname93"; row["dsc3line5"] = ""; row["dsc3texta5"] = ""; row["dsc3textb5"] = ""; row["dsc3calca5"] = ""; }
    if (row["skilldesc"] === "bone spirit") { row["dsc3textb3"] = "skillname72"; row["dsc3textb4"] = "skillname84"; row["dsc3line5"] = ""; row["dsc3texta5"] = ""; row["dsc3textb5"] = ""; row["dsc3calca5"] = ""; }
    if (row["skilldesc"] === "teeth") { row["dsc3textb2"] = "skillname72"; row["dsc3textb4"] = "skillname93"; row["dsc3line5"] = ""; row["dsc3texta5"] = ""; row["dsc3textb5"] = ""; row["dsc3calca5"] = ""; }
  }
  if (config.weaken) { if (row["skilldesc"] === "weaken") { row["descline4"] = 74; row["desctexta4"] = "StrSkillMagResist"; row["desccalca4"] = "-(par7 + (lvl - 1) * par8)"; } }
  if (config.poison_dagger) { if (row["skilldesc"] === "poison explosion") { row["desccalca3"] = "enma"; row["desccalcb3"] = "exma"; row["dsc3line1"] = ''; row["dsc3texta1"] = ''; row["dsc3textb1"] = ''; row["dsc3calca1"] = ''; row["dsc3line2"] = ''; row["dsc3texta2"] = ''; row["dsc3textb2"] = ''; row["dsc3calca2"] = ''; row["dsc3line3"] = ''; row["dsc3texta3"] = ''; row["dsc3textb3"] = ''; row["dsc3calca3"] = ''; row["descline5"] = 74; row["desctexta5"] = 'Moditemenrespoissk'; row["desccalca5"] = 'ln34'; row["descline6"] = 36; row["desctexta6"] = 'StrSkillDurationSingular'; row["desctextb6"] = "StrSkill20"; row["desccalca6"] = 'len/25'; } }
  if (config.raise_skeletal_mage) { if (row["skilldesc"] === "raise skeletal mage") { row["desccalca2"] = "(lvl < 4) ?lvl:(2+lvl/4)"; } }
  if (config.fire_golem) { if (row["skilldesc"] === "firegolem") { row["descline5"] = 74; row["desctexta5"] = "StrSkill54"; row["desccalca5"] = "-(skill('Holy Fire Golem'.par3) + (lvl - 1) * skill('Holy Fire Golem'.par4))"; row["desccalca2"] = "sklvl('Holy Fire Golem'.ln56.edmn)"; row["desccalcb2"] = "sklvl('Holy Fire Golem'.ln56.edmx)*((100+sklvl('Holy Fire Golem'.ln56.par6))/100)"; row["desccalca3"] = "edmn+sklvl('Holy Fire Golem'.ln56.edmn)*sklvl('Holy Fire Golem'.ln56.par5)"; row["desccalcb3"] = "edmx+sklvl('Holy Fire Golem'.ln56.edmx)*sklvl('Holy Fire Golem'.ln56.par5)"; row["dsc3line6"] = ""; row["dsc3texta6"] = ""; row["dsc3textb6"] = ""; row["dsc3calca6"] = ""; } }
  if (config.blood_golem) { if (row["skilldesc"] === "bloodgolem") { row["descline5"] = 74; row["desctexta5"] = "StrSkill100"; row["desccalca5"] = "skill('Blood Golem Oak Sage'.par1) + (lvl - 1) * skill('Blood Golem Oak Sage'.par2)"; row["dsc3line5"] = ""; row["dsc3texta5"] = ""; row["dsc3textb5"] = ""; row["dsc3calca5"] = ""; } }
});

D2RMM.writeTsv(skilldescFilename, skilldesc);

// missiles.txt
const missilesFilename = 'global\\excel\\missiles.txt';
const missiles = D2RMM.readTsv(missilesFilename);

// #4 Raise Skeletal Mage
// Improve Missiles
// Set poison damage HitShift to 1
// Faster missiles
if (config.raise_skeletal_mage) { var missileDamageMultiplier = config.missile_damage_multiplier; missiles.rows.forEach(row => { if (row["Missile"] === "necromage1" || row["Missile"] === "necromage2" || row["Missile"] === "necromage3" || row["Missile"] === "necromage4") { row["EMin"] = row["EMin"] * missileDamageMultiplier; row["MinELev1"] = row["MinELev1"] * missileDamageMultiplier; row["MinELev2"] = row["MinELev2"] * missileDamageMultiplier; row["MinELev3"] = row["MinELev3"] * missileDamageMultiplier; row["MinELev4"] = row["MinELev4"] * missileDamageMultiplier; row["MinELev5"] = row["MinELev5"] * missileDamageMultiplier; row["EMax"] = row["EMax"] * missileDamageMultiplier; row["MaxELev1"] = row["MaxELev1"] * missileDamageMultiplier; row["MaxELev2"] = row["MaxELev2"] * missileDamageMultiplier; row["MaxELev3"] = row["MaxELev3"] * missileDamageMultiplier; row["MaxELev4"] = row["MaxELev4"] * missileDamageMultiplier; row["MaxELev5"] = row["MaxELev5"] * missileDamageMultiplier; if (row["EType"] === "pois") { row["HitShift"] = 1; } row["Vel"] = 22; row["MaxVel"] = 22; } }); }

D2RMM.writeTsv(missilesFilename, missiles);

// skills.json
const skillsJsonFileName = 'local\\lng\\strings\\skills.json';
const skillsJson = D2RMM.readJson(skillsJsonFileName);

// #1 Bone Spear skill description json
if (config.bone_spear) { skillsJson.push( { "id": 80002, "Key": "StrSkill80002", "enUS": "%d bone spear", "zhTW": "%d bone spear", "deDE": "%d bone spear", "esES": "%d bone spear", "frFR": "%d bone spear", "itIT": "%d bone spear", "koKR": "%d bone spear", "plPL": "%d bone spear", "esMX": "%d bone spear", "jaJP": "%d bone spear", "ptBR": "%d bone spear", "ruRU": "%d bone spear", "zhCN": "%d bone spear" } ); }
if (config.weaken) { skillsJson.push( { "id": 80003, "Key": "StrSkillMagResist", "enUS": "Resist Magic: %+d%%", "zhTW": "Resist Magic: %+d%%", "deDE": "Resist Magic: %+d%%", "esES": "Resist Magic: %+d%%", "frFR": "Resist Magic: %+d%%", "itIT": "Resist Magic: %+d%%", "koKR": "Resist Magic: %+d%%", "plPL": "Resist Magic: %+d%%", "esMX": "Resist Magic: %+d%%", "jaJP": "Resist Magic: %+d%%", "ptBR": "Resist Magic: %+d%%", "ruRU": "Resist Magic: %+d%%", "zhCN": "Resist Magic: %+d%%" } ); }

// #1 Bone Spear skill description json
// #2 Weaken skill description json
// #3 poison explosion skill description json
// #5 Fire Golem
// #6 Blood Golem  
skillsJson.forEach(row => {
  if (config.bone_spear) { if (row["id"] === 4711) { row["enUS"] = "summons a deadly spike of bone to impale your enemies.\nGains an extra bone spear every 10 level"; } }  
  if (config.weaken) { if (row["id"] === 4663) { row["enUS"] = "curses a group of enemies,\nreducing the amount of damage they inflict\nLowers Magical Resistance of Monsters"; } }  
  if (config.poison_dagger) { if (row["id"] === 4665) { row["enUS"] = "Poison Freak"; } if (row["id"] === 4667) { row["enUS"] = "Adds poison attack to you and your party (including minions)\nDecreases enemy Poison Resistance while active"; } if (row["id"] === 4668) { row["enUS"] = "Poison Freak"; } }
  if (config.fire_golem) { if (row["id"] === 4751) { row["enUS"] = row["enUS"] + "\n" + "Reduces the resistances of enemies"; } }
  if (config.blood_golem) { if (row["id"] === 4715) { row["enUS"] = "Creates a golem that shares with you the life it steals\nApplies Open Wounds on every attack\nIncreases the life for you and your party\n(including minions)"; } }

});

D2RMM.writeJson(skillsJsonFileName, skillsJson);


// #7 Copy curse skill tree sprite
// overwrite any conflicts
if (config.no_curse_prereq) {
  D2RMM.copyFile(
    'hd\\global\\ui\\spells\\skill_trees\\neskilltree.sprite',
    'hd\\global\\ui\\spells\\skill_trees\\neskilltree.sprite',
    true 
  );
}

