{
	AtomicReference<IItemHandler> _iitemhandlerref = new AtomicReference<>();
	${input$entity}.getCapability(ForgeCapabilities.ITEM_HANDLER, null).ifPresent(capability -> _iitemhandlerref.set(capability));
	if (_iitemhandlerref.get() != null) {
		for(int _idx = 0; _idx < _iitemhandlerref.get().getSlots(); _idx++) {
			ItemStack itemstackiterator = _iitemhandlerref.get().getStackInSlot(_idx).copy();
			${statement$foreach}
		}
	}
}