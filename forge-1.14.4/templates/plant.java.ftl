<#--
 # MCreator (https://mcreator.net/)
 # Copyright (C) 2020 Pylo and contributors
 # 
 # This program is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 # 
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 # 
 # You should have received a copy of the GNU General Public License
 # along with this program.  If not, see <https://www.gnu.org/licenses/>.
 # 
 # Additional permission for code generator templates (*.ftl files)
 # 
 # As a special exception, you may create a larger work that contains part or 
 # all of the MCreator code generator templates (*.ftl files) and distribute 
 # that work under terms of your choice, so long as that work isn't itself a 
 # template for code generation. Alternatively, if you modify or redistribute 
 # the template itself, you may (at your option) remove this special exception, 
 # which will cause the template and the resulting code generator output files 
 # to be licensed under the GNU General Public License without this special 
 # exception.
-->

<#-- @formatter:off -->
<#include "procedures.java.ftl">
<#include "mcitems.ftl">

package ${package}.block;

@${JavaModName}Elements.ModElement.Tag public class ${name}Block extends ${JavaModName}Elements.ModElement {

	@ObjectHolder("${modid}:${registryname}")
	public static final Block block = null;

	<#if data.hasTileEntity>
	@ObjectHolder("${modid}:${registryname}")
	public static final TileEntityType<CustomTileEntity> tileEntityType = null;
	</#if>

	public ${name}Block(${JavaModName}Elements instance) {
		super(instance, ${data.getModElement().getSortID()});

		<#if data.hasTileEntity>
		FMLJavaModLoadingContext.get().getModEventBus().register(this);
		</#if>
	}

	@Override public void initElements() {
		elements.blocks.add(() -> new BlockCustomFlower());
		elements.items.add(() -> new <#if data.plantType == "double">Tall</#if>BlockItem(block, new Item.Properties().group(${data.creativeTab})).setRegistryName(block.getRegistryName()));
	}

	<#if data.hasTileEntity>
	@SubscribeEvent public void registerTileEntity(RegistryEvent.Register<TileEntityType<?>> event) {
		event.getRegistry().register(TileEntityType.Builder.create(CustomTileEntity::new, block).build(null).setRegistryName("${registryname}"));
	}
	</#if>

	<#if (data.spawnWorldTypes?size > 0)>
	@Override public void init(FMLCommonSetupEvent event) {
		<#if data.plantType == "normal">
			<#if data.staticPlantGenerationType == "Flower">
			FlowersFeature feature = new FlowersFeature(NoFeatureConfig::deserialize) {
				@Override public BlockState getRandomFlower(Random random, BlockPos pos) {
      				return block.getDefaultState();
   				}
			<#else>
			GrassFeature feature = new GrassFeature(GrassFeatureConfig::deserialize) {
			</#if>

				@Override public boolean place(IWorld world, ChunkGenerator generator, Random random, BlockPos pos,
						<#if data.staticPlantGenerationType == "Flower">
						NoFeatureConfig config
						<#else>
						GrassFeatureConfig config
						</#if>
				) {
					DimensionType dimensionType = world.getDimension().getType();
					boolean dimensionCriteria = false;

    				<#list data.spawnWorldTypes as worldType>
						<#if worldType=="Surface">
							if(dimensionType == DimensionType.OVERWORLD)
								dimensionCriteria = true;
						<#elseif worldType=="Nether">
							if(dimensionType == DimensionType.THE_NETHER)
								dimensionCriteria = true;
						<#elseif worldType=="End">
							if(dimensionType == DimensionType.THE_END)
								dimensionCriteria = true;
						<#else>
							if(dimensionType == ${(worldType.toString().replace("CUSTOM:", ""))}Dimension.type)
								dimensionCriteria = true;
						</#if>
					</#list>

					if(!dimensionCriteria)
						return false;

					<#if hasCondition(data.generateCondition)>
					int x = pos.getX();
					int y = pos.getY();
					int z = pos.getZ();
					if (!<@procedureOBJToConditionCode data.generateCondition/>)
						return false;
					</#if>

					return super.place(world, generator, random, pos, config);
				}
			};
		<#elseif data.plantType == "growapable">
			Feature<NoFeatureConfig> feature = new Feature<NoFeatureConfig>(NoFeatureConfig::deserialize) {
				@Override public boolean place(IWorld world, ChunkGenerator generator, Random random, BlockPos pos, NoFeatureConfig config) {
					DimensionType dimensionType = world.getDimension().getType();
					boolean dimensionCriteria = false;

    				<#list data.spawnWorldTypes as worldType>
						<#if worldType=="Surface">
							if(dimensionType == DimensionType.OVERWORLD)
								dimensionCriteria = true;
						<#elseif worldType=="Nether">
							if(dimensionType == DimensionType.THE_NETHER)
								dimensionCriteria = true;
						<#elseif worldType=="End">
							if(dimensionType == DimensionType.THE_END)
								dimensionCriteria = true;
						<#else>
							if(dimensionType == ${(worldType.toString().replace("CUSTOM:", ""))}Dimension.type)
								dimensionCriteria = true;
						</#if>
					</#list>

					if(!dimensionCriteria)
						return false;

					<#if hasCondition(data.generateCondition)>
					int x = pos.getX();
					int y = pos.getY();
					int z = pos.getZ();
					if (!<@procedureOBJToConditionCode data.generateCondition/>)
						return false;
					</#if>

					int generated = 0;
      				for(int j = 0; j < ${data.frequencyOnChunks}; ++j) {
						BlockPos blockpos = pos.add(random.nextInt(4) - random.nextInt(4), 0, random.nextInt(4) - random.nextInt(4));
						if (world.isAirBlock(blockpos)) {
							BlockPos blockpos1 = blockpos.down();
							int k = 1 + random.nextInt(random.nextInt(${data.growapableMaxHeight}) + 1);
							k = Math.min(${data.growapableMaxHeight}, k);
							for(int l = 0; l < k; ++l) {
								if (block.getDefaultState().isValidPosition(world, blockpos)) {
									world.setBlockState(blockpos.up(l), block.getDefaultState(), 2);
									generated++;
								}
							}
						}
      				}
      				return generated > 0;
				}
			};
		<#elseif data.plantType == "double">
		    <#if data.doublePlantGenerationType == "Flower"> DoublePlantFeature feature = new DoublePlantFeature(DoublePlantConfig::deserialize)
		    <#else> Feature<NoFeatureConfig> feature = new Feature<NoFeatureConfig>(NoFeatureConfig::deserialize) </#if> {
		        @Override public boolean place(IWorld world, ChunkGenerator generator, Random random, BlockPos pos,
		        <#if data.doublePlantGenerationType == "Flower">DoublePlant<#else>NoFeature</#if>Config config) {
                					DimensionType dimensionType = world.getDimension().getType();
                		boolean dimensionCriteria = false;

                    	<#list data.spawnWorldTypes as worldType>
                			<#if worldType=="Surface">
                				if(dimensionType == DimensionType.OVERWORLD)
                					dimensionCriteria = true;
                			<#elseif worldType=="Nether">
                				if(dimensionType == DimensionType.THE_NETHER)
                					dimensionCriteria = true;
                			<#elseif worldType=="End">
                				if(dimensionType == DimensionType.THE_END)
                					dimensionCriteria = true;
                			<#else>
                		    	if(dimensionType == ${(worldType.toString().replace("CUSTOM:", ""))}Dimension.type)
                		    		dimensionCriteria = true;
                			</#if>
                		</#list>

                		if(!dimensionCriteria)
                			return false;

                		<#if hasCondition(data.generateCondition)>
                		    int x = pos.getX();
                		    int y = pos.getY();
                		    int z = pos.getZ();
                		    if (!<@procedureOBJToConditionCode data.generateCondition/>)
                		    	return false;
                		</#if>

                        <#if data.doublePlantGenerationType == "Flower">
                	    return super.place(world, generator, random, pos, config);
                	    <#else>
                	    for (BlockState blockstate = world.getBlockState(pos); (blockstate.isAir() || blockstate.isIn(BlockTags.LEAVES))
                        			&& pos.getY() > 0; blockstate = world.getBlockState(pos)) {
                        	pos = pos.down();
                        }
                        int i = 0;
                        for (int j = 0; j < 128; ++j) {
                        	BlockPos blockpos = pos.add(random.nextInt(8) - random.nextInt(8), random.nextInt(4) - random.nextInt(4),
                        			random.nextInt(8) - random.nextInt(8));
                        	if (world.isAirBlock(blockpos) && block.getDefaultState().isValidPosition(world, blockpos)) {
                        		((DoublePlantBlock) block).placeAt(world, blockpos, 2);
                        		++i;
                        	}
                        }
                        return i > 0;
                	    </#if>
                    }
                };
		</#if>

		for (Biome biome : ForgeRegistries.BIOMES.getValues()) {
			<#if data.restrictionBiomes?has_content>
				boolean biomeCriteria = false;
				<#list data.restrictionBiomes as restrictionBiome>
					<#if restrictionBiome.canProperlyMap()>
					if (ForgeRegistries.BIOMES.getKey(biome).equals(new ResourceLocation("${restrictionBiome}")))
						biomeCriteria = true;
					</#if>
				</#list>
				if (!biomeCriteria)
					continue;
			</#if>

			<#if (data.plantType == "normal" && data.staticPlantGenerationType == "Grass") || (data.plantType == "double" && data.doublePlantGenerationType == "Grass")>
			biome.addFeature(GenerationStage.Decoration.VEGETAL_DECORATION, Biome.createDecoratedFeature(feature,
			    new <#if data.plantType == "normal">GrassFeatureConfig(block.getDefaultState())<#else>NoFeatureConfig()</#if>,
					Placement.NOISE_HEIGHTMAP_32, new NoiseDependant(-0.8, 0, ${data.frequencyOnChunks})
			));
			<#else>
			biome.addFeature(GenerationStage.Decoration.VEGETAL_DECORATION, Biome.createDecoratedFeature(feature,
			<#if data.plantType == "double">new DoublePlantConfig(block.getDefaultState())<#else>IFeatureConfig.NO_FEATURE_CONFIG</#if>,
					Placement.<#if data.plantType == "normal" || data.plantType == "double">COUNT_HEIGHTMAP_32<#else>COUNT_HEIGHTMAP_DOUBLE</#if>, new FrequencyConfig(${data.frequencyOnChunks})
			));
			</#if>
		}
	}
	</#if>

	public static class BlockCustomFlower extends <#if data.plantType == "normal">Flower<#elseif data.plantType == "growapable">SugarCane<#elseif data.plantType == "double">DoublePlant</#if>Block {

		public BlockCustomFlower() {
			super(<#if data.plantType == "normal">Effects.SATURATION, 0,</#if>
					<#if data.colorOnMap != "DEFAULT">
					Block.Properties.create(Material.PLANTS, MaterialColor.${generator.map(data.colorOnMap, "mapcolors")})
					<#else>
					Block.Properties.create(Material.PLANTS)
					</#if>
					<#if data.plantType == "growapable" || data.forceTicking>
					.tickRandomly()
					</#if>
					.doesNotBlockMovement()
					.sound(SoundType.${data.soundOnStep})
					<#if data.unbreakable>
					.hardnessAndResistance(-1, 3600000)
					<#else>
					.hardnessAndResistance(${data.hardness}f, ${data.resistance}f)
					</#if>
					.lightValue(${(data.luminance * 15)?round})
			);
			setRegistryName("${registryname}");
		}

		<#if data.specialInfo?has_content>
		@Override @OnlyIn(Dist.CLIENT) public void addInformation(ItemStack itemstack, IBlockReader world, List<ITextComponent> list, ITooltipFlag flag) {
			super.addInformation(itemstack, world, list, flag);
			<#list data.specialInfo as entry>
			list.add(new StringTextComponent("${JavaConventions.escapeStringForJava(entry)}"));
			</#list>
		}
		</#if>

        <#if data.isReplaceable>
        @Override public boolean isReplaceable(BlockState state, BlockItemUseContext useContext) {
			return true;
		}
        </#if>

		<#if data.flammability != 0>
		@Override public int getFlammability(BlockState state, IBlockReader world, BlockPos pos, Direction face) {
			return ${data.flammability};
		}
		</#if>

		<#if generator.map(data.aiPathNodeType, "pathnodetypes") != "DEFAULT">
		@Override public PathNodeType getAiPathNodeType(BlockState state, IBlockReader world, BlockPos pos, MobEntity entity) {
			return PathNodeType.${generator.map(data.aiPathNodeType, "pathnodetypes")};
		}
		</#if>

		<#if data.offsetType != "XZ">
		@Override public Block.OffsetType getOffsetType() {
			return Block.OffsetType.${data.offsetType};
		}
		</#if>

		<#if data.fireSpreadSpeed != 0>
		@Override public int getFireSpreadSpeed(BlockState state, IBlockReader world, BlockPos pos, Direction face) {
			return ${data.fireSpreadSpeed};
		}
		</#if>

		<#if data.creativePickItem?? && !data.creativePickItem.isEmpty()>
		@Override public ItemStack getPickBlock(BlockState state, RayTraceResult target, IBlockReader world, BlockPos pos, PlayerEntity player) {
        	return ${mappedMCItemToItemStackCode(data.creativePickItem, 1)};
    	}
        </#if>

		<#if data.emissiveRendering>
        @OnlyIn(Dist.CLIENT) @Override public int getPackedLightmapCoords(BlockState state, IEnviromentBlockReader worldIn, BlockPos pos) {
			return 15728880;
		}
		</#if>

        <#if !data.useLootTableForDrops>
		    <#if data.dropAmount != 1 && !(data.customDrop?? && !data.customDrop.isEmpty())>
		    @Override public List<ItemStack> getDrops(BlockState state, LootContext.Builder builder) {
                <#if data.plantType == "double">
                if(state.get(BlockStateProperties.DOUBLE_BLOCK_HALF) != DoubleBlockHalf.LOWER)
                    return Collections.emptyList();
                </#if>

				List<ItemStack> dropsOriginal = super.getDrops(state, builder);
			    if(!dropsOriginal.isEmpty())
				    return dropsOriginal;
			    return Collections.singletonList(new ItemStack(this, ${data.dropAmount}));
		    }
		    <#elseif data.customDrop?? && !data.customDrop.isEmpty()>
		    @Override public List<ItemStack> getDrops(BlockState state, LootContext.Builder builder) {
                <#if data.plantType == "double">
                if(state.get(BlockStateProperties.DOUBLE_BLOCK_HALF) != DoubleBlockHalf.LOWER)
                    return Collections.emptyList();
                </#if>

				List<ItemStack> dropsOriginal = super.getDrops(state, builder);
			    if(!dropsOriginal.isEmpty())
				    return dropsOriginal;
			    return Collections.singletonList(${mappedMCItemToItemStackCode(data.customDrop, data.dropAmount)});
		    }
		    <#else>
		    @Override public List<ItemStack> getDrops(BlockState state, LootContext.Builder builder) {
                <#if data.plantType == "double">
                if(state.get(BlockStateProperties.DOUBLE_BLOCK_HALF) != DoubleBlockHalf.LOWER)
                    return Collections.emptyList();
                </#if>

				List<ItemStack> dropsOriginal = super.getDrops(state, builder);
			    if(!dropsOriginal.isEmpty())
				    return dropsOriginal;
			    return Collections.singletonList(new ItemStack(this, 1));
		    }
            </#if>
        </#if>

		@Override public PlantType getPlantType(IBlockReader world, BlockPos pos) {
			return PlantType.${data.growapableSpawnType};
		}

        <#if hasProcedure(data.onBlockAdded)>
		@Override public void onBlockAdded(BlockState state, World world, BlockPos pos, BlockState oldState, boolean moving) {
			super.onBlockAdded(state, world, pos, oldState, moving);
			int x = pos.getX();
			int y = pos.getY();
			int z = pos.getZ();
			<@procedureOBJToCode data.onBlockAdded/>
		}
        </#if>

        <#if hasProcedure(data.onTickUpdate) || data.plantType == "growapable">
		@Override public void tick(BlockState state, World world, BlockPos pos, Random random) {
			<#if hasProcedure(data.onTickUpdate)>
                int x = pos.getX();
			    int y = pos.getY();
			    int z = pos.getZ();
                <@procedureOBJToCode data.onTickUpdate/>
            </#if>

            <#if data.plantType == "growapable">
			if (!state.isValidPosition(world, pos)) {
			   world.destroyBlock(pos, true);
			} else if (world.isAirBlock(pos.up())) {
			   int i = 1;
			   for(;world.getBlockState(pos.down(i)).getBlock() == this; ++i);
			   if (i < ${data.growapableMaxHeight}) {
			      int j = state.get(AGE);
			      if (j == 15) {
			         world.setBlockState(pos.up(), getDefaultState());
			         world.setBlockState(pos, state.with(AGE, 0), 4);
			      } else {
			         world.setBlockState(pos, state.with(AGE, j + 1), 4);
			      }
			   }
			}
            </#if>
		}
        </#if>

        <#if hasProcedure(data.onRandomUpdateEvent)>
		@OnlyIn(Dist.CLIENT) @Override
		public void animateTick(BlockState state, World world, BlockPos pos, Random random) {
			super.animateTick(state, world, pos, random);
			PlayerEntity entity = Minecraft.getInstance().player;
			int x = pos.getX();
			int y = pos.getY();
			int z = pos.getZ();
			<@procedureOBJToCode data.onRandomUpdateEvent/>
		}
        </#if>

        <#if hasProcedure(data.onNeighbourBlockChanges)>
		@Override
		public void neighborChanged(BlockState state, World world, BlockPos pos, Block neighborBlock, BlockPos fromPos, boolean isMoving) {
			super.neighborChanged(state, world, pos, neighborBlock, fromPos, isMoving);
			int x = pos.getX();
			int y = pos.getY();
			int z = pos.getZ();
			<@procedureOBJToCode data.onNeighbourBlockChanges/>
		}
        </#if>

        <#if hasProcedure(data.onEntityCollides)>
		@Override public void onEntityCollision(BlockState state, World world, BlockPos pos, Entity entity) {
			super.onEntityCollision(state, world, pos, entity);
			int x = pos.getX();
			int y = pos.getY();
			int z = pos.getZ();
			<@procedureOBJToCode data.onEntityCollides/>
		}
        </#if>

        <#if hasProcedure(data.onDestroyedByPlayer)>
		@Override
		public boolean removedByPlayer(BlockState state, World world, BlockPos pos, PlayerEntity entity,
				boolean willHarvest, IFluidState fluid) {
			boolean retval = super.removedByPlayer(state, world, pos, entity, willHarvest, fluid);
			int x = pos.getX();
			int y = pos.getY();
			int z = pos.getZ();
			<@procedureOBJToCode data.onDestroyedByPlayer/>
			return retval;
		}
        </#if>

        <#if hasProcedure(data.onDestroyedByExplosion)>
		@Override public void onExplosionDestroy(World world, BlockPos pos, Explosion e) {
			super.onExplosionDestroy(world, pos, e);
			int x = pos.getX();
			int y = pos.getY();
			int z = pos.getZ();
			<@procedureOBJToCode data.onDestroyedByExplosion/>
		}
        </#if>

        <#if hasProcedure(data.onStartToDestroy)>
		@Override public void onBlockClicked(BlockState state, World world, BlockPos pos, PlayerEntity entity) {
			super.onBlockClicked(state, world, pos, entity);
			int x = pos.getX();
			int y = pos.getY();
			int z = pos.getZ();
			<@procedureOBJToCode data.onStartToDestroy/>
		}
        </#if>

        <#if hasProcedure(data.onBlockPlacedBy)>
		@Override
		public void onBlockPlacedBy(World world, BlockPos pos, BlockState state, LivingEntity entity, ItemStack itemstack) {
			super.onBlockPlacedBy(world, pos, state, entity, itemstack);
			int x = pos.getX();
			int y = pos.getY();
			int z = pos.getZ();
			<@procedureOBJToCode data.onBlockPlacedBy/>
		}
        </#if>

        <#if hasProcedure(data.onRightClicked)>
		@Override public boolean onBlockActivated(BlockState state, World world, BlockPos pos, PlayerEntity entity, Hand hand, BlockRayTraceResult hit) {
			boolean retval = super.onBlockActivated(state, world, pos, entity, hand, hit);
			int x = pos.getX();
			int y = pos.getY();
			int z = pos.getZ();
			Direction direction = hit.getFace();
			<@procedureOBJToCode data.onRightClicked/>
			return true;
		}
        </#if>

		<#if data.hasTileEntity>
		@Override public boolean hasTileEntity(BlockState state) {
			return true;
		}

		@Override public TileEntity createTileEntity(BlockState state, IBlockReader world) {
			return new CustomTileEntity();
		}

		@Override
		public boolean eventReceived(BlockState state, World world, BlockPos pos, int eventID, int eventParam) {
			super.eventReceived(state, world, pos, eventID, eventParam);
			TileEntity tileentity = world.getTileEntity(pos);
			return tileentity == null ? false : tileentity.receiveClientEvent(eventID, eventParam);
		}
		</#if>

	}

	<#if data.hasTileEntity>
	private static class CustomTileEntity extends TileEntity {

		public CustomTileEntity() {
			super(tileEntityType);
		}

		@Override public SUpdateTileEntityPacket getUpdatePacket() {
			return new SUpdateTileEntityPacket(this.pos, 0, this.getUpdateTag());
		}

		@Override public CompoundNBT getUpdateTag() {
			return this.write(new CompoundNBT());
		}

		@Override public void onDataPacket(NetworkManager net, SUpdateTileEntityPacket pkt) {
			this.read(pkt.getNbtCompound());
		}

	}
	</#if>

}
<#-- @formatter:on -->