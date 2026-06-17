USE hbo_db;
GO

INSERT INTO dbo.plans
    (name, price, description)
VALUES
    ('Basic with Ads', 18.90, 'Streaming on 1 screen, with ads.'),
    ('Standard', 34.90, 'Streaming on 2 simultaneous screens, HD.'),
    ('Platinum', 55.90, 'Streaming on 4 screens, 4K UHD and Dolby Atmos audio.');
GO