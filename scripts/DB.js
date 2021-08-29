

const INCOMES_TABLE_NAME = "Incomes";
const NEEDS_TABLE_NAME = "Needs";
const CURRENCY_TABLE_NAME = "Currency";
const EXPENSES_TABLE_NAME = "Expenses";
const ICONS_TABLE_NAME = "Icons";
const LAST_UPDATE_TIME_TABLE_NAME = "LastUpdateTime";
const SETTINGS_TABLE_NAME = "Settings";

const DEFAUL_ICON = '<svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 0 24 24" width="24px" fill="#FFFFFF"><path d="M0 0h24v24H0z" fill="none"/><path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/></svg>';

function execute(tx, query, values) {
    console.log("query:", query);
    if(values) {
        console.log("values:", JSON.stringify(values));
    }
    return values ? tx.executeSql(query, values) : tx.executeSql(query);
}

function tableExists(tx, name) {
    let res = execute(tx, "SELECT name FROM sqlite_master WHERE type='table' AND name='" + name + "'");
    return res.rows.length > 0;
}


function createTable(tx, name, columns) {
    let query = "CREATE TABLE IF NOT EXISTS " + name;
    query += "(";

    for(let i = 0; i < columns.length - 1; i++) {
        query += columns[i] + ", ";
    }

    query += columns[columns.length - 1] + ");";

    execute(tx, query);
}

function dropTable(tx, name) {
    execute(tx, "DROP TABLE IF EXISTS " + name + ";");
}

function getTableNames(tx) {
    return select(tx, ["name"], "sqlite_master", "type='table'");
}

function dropDB(tx) {
    let tables = getTableNames(tx);
    for(let i = 0; i < tables.length; i++) {
        dropTable(tx, tables[i].name);
    }
}

function insert(tx, tableName, properties, values) {
    let query = "INSERT INTO " + tableName;
    query += "(";

    for(let i = 0; i < properties.length - 1; i++) {
        query += properties[i] + ", ";
    }

    query += properties[properties.length - 1] + ")";

    query += " VALUES("

    for(let i = 0; i < properties.length - 1; i++) {
        query += "?, ";
    }

    query += "?);";

    execute(tx, query, values);
}

function select(tx, what, from, where) {
    let query = "SELECT ";

    for(let i = 0; i < what.length - 1; i++) {
        query += what[i] + ", "
    }

    query += what[what.length - 1];

    query += " FROM " + from;

    if(where) {
        query += " WHERE " + where + ";";
    }

    let result = execute(tx, query);

    let ret = [];

    for(let i = 0; i < result.rows.length; i++) {
        let row = result.rows.item(i);
        ret.push(row);
    }

    console.log("return: ", JSON.stringify(ret));

    return ret;


}

function setLastUpdateTime(tx, date) {
    dropTable(tx, LAST_UPDATE_TIME_TABLE_NAME);
    createTable(tx, LAST_UPDATE_TIME_TABLE_NAME, ["date INTEGER"]);
    insert(tx, LAST_UPDATE_TIME_TABLE_NAME, ["date"], [date ? date : Date.now()]);
}

function getLastUpdateTime(tx) {
    let res = execute(tx, "SELECT date FROM " + LAST_UPDATE_TIME_TABLE_NAME);
    return Number(res.rows.item(0).date);
}

function initIncomes(tx) {
    if(!tableExists(tx, INCOMES_TABLE_NAME)) {
        createTable(tx, INCOMES_TABLE_NAME, ["date INTEGER", "currency TEXT", "value FLOAT"]);
    }
}

function initNeeds(tx) {
    if(!tableExists(tx, NEEDS_TABLE_NAME)) {
        createTable(tx, NEEDS_TABLE_NAME, ["name TEXT", "icon INTEGER"]);
        insert(tx, NEEDS_TABLE_NAME, ["name", "icon"], ["Other", 1]);
    }
}

function initCurrency(tx) {
    if(!tableExists(tx, CURRENCY_TABLE_NAME)) {
        createTable(tx, CURRENCY_TABLE_NAME, ["name TEXT", "rate FLOAT"]);
    }
}


function initExpenses(tx) {
    if(!tableExists(tx, EXPENSES_TABLE_NAME)) {
        createTable(tx, EXPENSES_TABLE_NAME, ["date INTEGER", "currency TEXT", "value FLOAT", "need TEXT"]);
    }
}

function initIcons(tx) {
    if(!tableExists(tx, ICONS_TABLE_NAME)) {
        createTable(tx, ICONS_TABLE_NAME, ["svg TEXT"]);
        insert(tx, ICONS_TABLE_NAME, ["svg"], [DEFAUL_ICON]);
    }
}


function initSettings(tx) {
    if(!tableExists(tx, SETTINGS_TABLE_NAME)) {
        createTable(tx, SETTINGS_TABLE_NAME, ["json TEXT"]);
    }
}

function getIconById(tx, id) {
    return select(tx, ["rowid", "svg"], ICONS_TABLE_NAME, "rowid=" + id)[0].svg;
}

function getAllIcons(tx) {
    return select(tx, ["rowid", "svg"], ICONS_TABLE_NAME);
}


function setSettings(tx, settings) {
    execute(tx, "DELETE FROM " + SETTINGS_TABLE_NAME);
    insert(tx, SETTINGS_TABLE_NAME, ["json"], [JSON.stringify(settings)]);
    setLastUpdateTime(tx);
}

function getSettings(tx) {
    let ret = select(tx, ["json"], SETTINGS_TABLE_NAME)[0];

    if(!ret) {
        return false;
    }

    return JSON.parse(ret.json);
}

function getAllExpensesWithNeed(tx, need) {
    return select(tx, ["*"], EXPENSES_TABLE_NAME, "need='" + need + "'");
}

function getCurrency(tx) {
    let res = select(tx, ["*"], CURRENCY_TABLE_NAME);
    let currency = {};

    for(let i = 0; i < res.length; i++) {
        currency[res[i].name] = res[i].rate;
    }

    return currency;
}

function addExpense(tx, currency, value, need) {
    insert(tx, EXPENSES_TABLE_NAME, ["date", "currency", "value", "need"], [Date.now(), currency, value, need]);
    setLastUpdateTime(tx);
}

function initDB(tx) {
    initIncomes(tx);
    initNeeds(tx);
    initCurrency(tx);
    initExpenses(tx);
    initIcons(tx);
    initSettings(tx);
    return getSettings(tx);
}
