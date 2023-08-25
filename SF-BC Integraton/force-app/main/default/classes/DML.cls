public with sharing class DML {
    public list < sObject > selectRecordsInList(list < String > whereList, string selectClause, string fromClause,
        string whereClause, string groupBy, string orderBy, string recordlimit,string offset) {
        String query = selectClause + ' ' + fromClause;
        if (whereClause != '') {
            query = query + ' ' + whereClause + 'whereList';
        }
        if (groupBy != '') {
            query = query + ' ' + groupBy;
        }
        if (orderBy != '') {
            query = query + ' ' + orderBy;
        }
        if (recordlimit != '') {
            query = query + ' ' + recordlimit;
        }
        if (offset != '') {
            query = query + ' ' + offset;
        }
        system.debug('DML --> selectRecords');
        system.debug(query);
        list < sObject > queryResult = Database.query(query);
        return queryResult;
    }
    public list < sObject > selectRecords(string selectClause, string fromClause,
        string whereClause, string groupBy, string orderBy, string recordlimit,string offset) {
        String query = selectClause + ' ' + fromClause;
        if (whereClause != '') {
            query = query + ' ' + whereClause;
        }
        if (groupBy != '') {
            query = query + ' ' + groupBy;
        }
        if (orderBy != '') {
            query = query + ' ' + orderBy;
        }
        if (recordlimit != '') {
            query = query + ' ' + recordlimit;
        }
        if (offset != '') {
            query = query + ' ' + offset;
        }
        system.debug('DML --> selectRecords');
        system.debug(query);
        list < sObject > queryResult = Database.query(query);
        return queryResult;
    }
    public sObject selectSingleRecord(string selectClause, string fromClause,
        string whereClause, string groupBy, string orderBy) {
        String query = selectClause + ' ' + fromClause;
        if (whereClause != '') {
            query = query + ' ' + whereClause;
        }
        if (groupBy != '') {
            query = query + ' ' + groupBy;
        }
        if (orderBy != '') {
            query = query + ' ' + orderBy;
        }
        query = query + ' limit 1';
        system.debug('DML --> selectSingleRecord');
        system.debug(query);
        sObject queryResult = Database.query(query);
        return queryResult;
    }
    public list < AggregateResult > selectAggregateRecords(string selectClause, string fromClause,
        string whereClause, string groupBy, string orderBy, string recordlimit) {
        String query = selectClause + ' ' + fromClause;
        if (whereClause != '') {
            query = query + ' ' + whereClause;
        }
        if (groupBy != '') {
            query = query + ' ' + groupBy;
        }
        if (orderBy != '') {
            query = query + ' ' + orderBy;
        }
        if (recordlimit != '') {
            query = query + ' ' + recordlimit;
        }
        list < AggregateResult > queryResult = Database.query(query);
        return queryResult;
    }
    public sObject insertRecord(sObject obj) {
        insert obj;
        return obj;
    }
    public List < sObject > insertRecord(List < sObject > obj) {
        insert obj;
        return obj;
    }
    public sObject updateRecord(sObject obj) {
        update obj;
        return obj;
    }
    public list < sObject > updateRecord(list < sObject > obj) {
        update obj;
        return obj;
    }
    public sObject upsertRecord(sObject obj) {
        upsert obj;
        return obj;
    }
    public list < sObject > upsertRecord(list < sObject > obj) {
        upsert obj;
        return obj;
    }
    public sObject upsertRecord(sObject obj, String matchFieldStr) {
        List < String > splitString = matchFieldStr.split('\\.');
        if (splitString[0].contains('EBizcharge_Setting__c')) {
            splitString[0] = 'EBizc__EBizcharge_Setting__c';
        }
        Schema.SobjectField matchField = Schema.getGlobalDescribe().get(splitString[0]).getDescribe().fields.getMap().get(splitString[1]);
        Database.upsert(obj, matchField);
        return obj;
    }
    public list < sObject > upsertRecord(list < sObject > obj, String matchFieldStr) {
        List < String > splitString = matchFieldStr.split('\\.');
        Schema.SobjectField matchField = Schema.getGlobalDescribe().get(splitString[0]).getDescribe().fields.getMap().get(splitString[1]);
        Database.upsert(obj, matchField);
        return obj;
    }
    public sObject deleteRecord(sObject obj) {
        Database.delete(obj);
        return obj;
    }
    public list < sObject > deleteRecord(list < sObject > obj) {
        Database.delete(obj);
        return obj;
    }
}