class_name BuyableData extends EntityData

enum SHOP_TYPE {
	RESOURCE,
	FARMING,
	BUILDING
}

@export var buy_price: int
@export var shop_to_sell_at: SHOP_TYPE
