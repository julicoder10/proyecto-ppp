public with sharing class LwcController {
    @AuraEnabled(cacheable=true)
    public static TrailWrapper getTrailWrapper(Id trailId) {
        // Llamada al método del servicio UnitService
        TrailWrapper wrapper = UnitService.getTrailWrapper(trailId);
        return wrapper;
    }

    @AuraEnabled(cacheable=true)
    public static UnitWrapper getUnitWrapper(Id unitId) {
        // Llamada al método del servicio UnitService
        UnitWrapper wrapper = UnitService.getUnitWrapper(unitId);
        return wrapper;
    }
}
