CREATE SCHEMA IF NOT EXISTS market_data;

CREATE TABLE IF NOT EXISTS market_data.prices_gr (
	start_time TIMESTAMPTZ NOT NULL,
	market VARCHAR(10) NOT NULL, --eg ida1, dam 
	cleared_price NUMERIC(10,2), 
	updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (start_time, market)
);

COMMENT ON TABLE market_data.prices_gr IS 'Αποτελέσματα τιμών αγορών ενέργειας Day Ahead Market & Intraday Market';
COMMENT ON COLUMN market_data.prices_gr.cleared_price IS 'Τιμές συστήματος (pay as cleared) σε EUR/MWh';

CREATE TABLE IF NOT EXISTS market_data.prices_neighbors (
	start_time TIMESTAMPTZ NOT NULL,
	country_code VARCHAR(10) NOT NULL, --eg bulgaria , italy 
	cleared_price NUMERIC(10,2),
	updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (start_time, country_code)
);

COMMENT ON TABLE market_data.prices_neighbors IS 'Αποτελέσματα τιμών Day Ahead Market από τις γειτονικές χώρες της Ελλάδας';
COMMENT ON COLUMN market_data.prices_neighbors.cleared_price IS 'Τιμές από τις γειτονικές αγορές σε EUR/MWh';

CREATE TABLE IF NOT EXISTS market_data.commodity_prices (
    target_date DATE NOT NULL,
    ttf_price NUMERIC(10, 2), -- Τιμή Φυσικού Αερίου (EUR/MWh)
    eua_price NUMERIC(10, 2), -- Τιμή Δικαιωμάτων Εκπομπών CO2 (EUR/tn)
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (target_date)
);

COMMENT ON TABLE market_data.commodity_prices IS 'Ημερήσιες τιμές κλεισίματος του Φυσικού Αερίου και των Ρύπων (CO2) (Gas & Carbon)';
COMMENT ON COLUMN market_data.commodity_prices.ttf_price IS 'Τιμή Title Transfer Facility (TTF) για την επόμενη ημέρα';
COMMENT ON COLUMN market_data.commodity_prices.eua_price IS 'Τιμή European Union Allowances (EUA) για εκπομπές CO2';

--------------------------------------------------------------------------------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS grid_ex_ante; --Απαιτήσεις από τον ΑΔΜΗΕ τα οποία τα έχω πχ πριν τρέξω κάποιο μοντέλο πρόβλεψης 

CREATE TABLE IF NOT EXISTS grid_ex_ante.isp_requirements (
	start_time TIMESTAMPTZ NOT NULL,
	isp_run VARCHAR(10) NOT NULL, -- αν ειναι ISP1, ISP2, ISP3
	load_forecast NUMERIC(10, 2),
	res_forecast NUMERIC(10, 2),
	mandatory_hydro NUMERIC(10, 2),
	commissioning NUMERIC(10, 2),
	reserve_requirements_up NUMERIC(10, 2),
	reserve_requirements_down NUMERIC(10, 2),
	updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (start_time, isp_run)
);

COMMENT ON TABLE grid_ex_ante.isp_requirements IS 'Οι προβλέψεις και οι απαιτήσεις απο την διαδικασία ενοποιημένου προγραμματισμού του ΑΔΜΗΕ';

CREATE TABLE IF NOT EXISTS grid_ex_ante.unit_availabilities (
	target_date DATE NOT NULL,
	unit_name VARCHAR(50) NOT NULL,
	isp_run VARCHAR(10) DEFAULT 'ISP1',
	available_publication NUMERIC(10, 2), --τι είχε στην ουσία διαθεσιμότητα όταν δημοσιεύτηκε
	available_estimation NUMERIC(10, 2), --τι προβλέπει για αύριο
	comments TEXT, 
	update_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (target_date, unit_name, isp_run)
);

COMMENT ON TABLE grid_ex_ante.unit_availabilities IS 'Η συνολική διαθεσιμότητα των μονάδων από τον ΑΔΜΗΕ';
COMMENT ON COLUMN grid_ex_ante.unit_availabilities.available_publication IS 'Τι είχε η κάθε μονάδα διαθέσιμο στην δημοσίευση του αρχείου από τον ΑΔΜΗΕ' ;
COMMENT ON COLUMN grid_ex_ante.unit_availabilities.available_estimation IS 'Τι προβλέπει ο ΑΔΜΗΕ να έχει η μονάδα διαθέσιμο για αύριο' ;

-------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS grid_ex_post; --Αποτελέσματα από τον ΑΔΜΗΕ

CREATE TABLE IF NOT EXISTS grid_ex_post.isp_system_results ( 
    start_time TIMESTAMPTZ NOT NULL,
    isp_run VARCHAR(10) NOT NULL,
    activated_energy_up NUMERIC(10, 2),   
    activated_energy_down NUMERIC(10, 2),
    price_energy_up NUMERIC(10, 2),       
    price_energy_down NUMERIC(10, 2),    
    
    system_load_actual NUMERIC(10, 2),   
    mandatory_hydro_cleared NUMERIC(10, 2), 
    res_cleared NUMERIC(10, 2),           
    thermal_cleared NUMERIC(10, 2),   
    hydro_cleared NUMERIC(10, 2),         
    dispatchable_load_cleared NUMERIC(10, 2),
    demand_response_cleared NUMERIC(10, 2),
    
    net_cbs_cleared NUMERIC(10, 2),       
    energy_surplus_deficit NUMERIC(10, 2),
    
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (start_time, isp_run)
);

COMMENT ON TABLE grid_ex_post.isp_system_results IS 'Συνολικά αποτελέσματα του ISP (Targets & Physical Clearing).';
COMMENT ON COLUMN grid_ex_post.isp_system_results.activated_energy_up IS 'Κρίσιμο για System Direction: Υψηλό Up σημαίνει σύστημα Short (Ανοδική πίεση στην ΟΤΑ).';

-------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS analytics_features;

--CREATE VIEW IF NOT EXISTS analytics_features.feature_store_dam ();

--CREATE VIEW IF NOT EXISTS analytics_features.economic_metrics ();


