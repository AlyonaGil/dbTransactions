CREATE TABLE IF NOT EXISTS "Currency"
(
    id   serial  NOT NULL
        CONSTRAINT currency_pk
            PRIMARY KEY,
    name varchar NOT NULL
);

CREATE TABLE IF NOT EXISTS "Payment_system_type"
(
    id   serial  NOT NULL
        CONSTRAINT payment_system_type_pk
            PRIMARY KEY,
    name varchar NOT NULL
);

CREATE TABLE IF NOT EXISTS "User_payment"
(
    id                                serial  NOT NULL
        CONSTRAINT user_payment_pk
            PRIMARY KEY,
    id_user                           varchar NOT NULL,
    id_payment_system_type            integer NOT NULL
        CONSTRAINT user_payment_payment_system_type_id_fk
            REFERENCES "Payment_system_type",
    payment_system_user_account_token varchar NOT NULL
);

CREATE TABLE IF NOT EXISTS "Games"
(
    id          serial  NOT NULL
        CONSTRAINT games_pk
            PRIMARY KEY,
    game        varchar NOT NULL,
    description varchar NOT NULL
);

CREATE TABLE IF NOT EXISTS "Users"
(
    id   varchar NOT NULL
        CONSTRAINT users_pk
            PRIMARY KEY,
    name varchar NOT NULL
);

CREATE TABLE IF NOT EXISTS "Payment_history"
(
    number   integer NOT NULL
        CONSTRAINT payment_history_pk
            PRIMARY KEY,
    date     date    NOT NULL,
    canceled integer NOT NULL
);

CREATE TABLE IF NOT EXISTS "Transactions"
(
    id_game                integer          NOT NULL
        CONSTRAINT transactions_games_id_fk
            REFERENCES "Games",
    purchase_item_quantity integer          NOT NULL,
    id_user                varchar          NOT NULL
        CONSTRAINT transactions_users_id_fk
            REFERENCES "Users",
    payment_number         integer          NOT NULL
        CONSTRAINT transactions_payment_history_number_fk
            REFERENCES "Payment_history",
    id_payment_currency    integer          NOT NULL
        CONSTRAINT transactions_currency_id_fk
            REFERENCES "Currency",
    payment_amount         double precision NOT NULL,
    vat                    double precision NOT NULL,
    id_user_payment        integer          NOT NULL
        CONSTRAINT transactions_user_payment_id_fk
            REFERENCES "User_payment",
    CONSTRAINT transactions_pk
        PRIMARY KEY (id_game, id_user, payment_number)
);

CREATE TABLE IF NOT EXISTS "Price"
(
    id_game                     integer          NOT NULL
        CONSTRAINT price_games_id_fk
            REFERENCES "Games",
    id_current_nominal_currency integer          NOT NULL
        CONSTRAINT price_currency_id_fk
            REFERENCES "Currency",
    current_nominal_amount      double precision NOT NULL,
    CONSTRAINT price_pk
        PRIMARY KEY (id_game, id_current_nominal_currency)
);

CREATE INDEX idx_canceled_date ON "Payment_history" (canceled, date);
CREATE INDEX idx_token ON "User_payment" (payment_system_user_account_token);

--Вывод всех успешно купленных за определенный период игр
SELECT DISTINCT g.game FROM "Transactions" tr
INNER JOIN "Games" g ON g.id=tr.id_game
INNER JOIN "Payment_history" ph ON tr.payment_number=ph.number
WHERE ph.canceled=0 AND ph.date BETWEEN '2020-01-01' AND '2020-01-03';

--Вывод всех платежей по указанному токену сохраненного аккаунта пользователя
SELECT tr.id_game, tr.purchase_item_quantity, tr.id_user, tr.payment_number, tr.id_payment_currency, tr.payment_amount, tr.vat, tr.id_user_payment
FROM "Transactions" tr
INNER JOIN "User_payment" up ON up.id=tr.id_user_payment
WHERE up.payment_system_user_account_token='gej-jacf-qrt';

--Вывод всех платежей по указанному токену сохраненного аккаунта за определенный период времени
SELECT tr.id_game, tr.purchase_item_quantity, tr.id_user, tr.payment_number, tr.id_payment_currency, tr.payment_amount, tr.vat, tr.id_user_payment
FROM "Transactions" tr
INNER JOIN "User_payment" up ON up.id=tr.id_user_payment
INNER JOIN "Payment_history" ph ON tr.payment_number=ph.number
WHERE up.payment_system_user_account_token='gej-jacf-qrt' AND ph.date BETWEEN '2020-01-01' AND '2020-01-03';