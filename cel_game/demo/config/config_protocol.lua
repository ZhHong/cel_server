local protocol = {
	--l->m
	["101"] = {service = "custom", func = "kick"},
	["102"] = {service = "custom", func = "login"},

	--m->l
	["201"] = {service = ".login_server", func = "register_gate"},
	["202"] = {service = ".login_server", func = "logout"},
	["203"] = {service = ".login_server", func = "tick_gate"},

	--l->a	
	["301"] = {service = ".app_dispatch", func = "dispatch"},

	--a->l	
	["401"] = {service = ".login_server", func = "web_dispatch"},

	--c->m
	["test"] = {func = "test"},
}
return protocol
