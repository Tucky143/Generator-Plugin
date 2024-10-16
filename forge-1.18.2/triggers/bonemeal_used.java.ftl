<#include "procedures.java.ftl">
@Mod.EventBusSubscriber public class ${name}Procedure {
	@SubscribeEvent public static void onBonemeal(BonemealEvent event) {
		<#assign dependenciesCode><#compress>
			<@procedureDependenciesCode dependencies, {
			"x": "event.getPos().getX()",
			"y": "event.getPos().getY()",
			"z": "event.getPos().getZ()",
			"world": "event.getWorld()",
			"itemstack": "event.getStack()",
			"entity": "event.getPlayer()",
			"blockstate": "event.getBlock()",
			"event": "event"
			}/>
		</#compress></#assign>
		execute(event<#if dependenciesCode?has_content>,</#if>${dependenciesCode});
	}