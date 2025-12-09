// tests/__mocks__/pg-promise.js

const mockDb = {
  many: jest.fn(),
  manyOrNone: jest.fn(),
  one: jest.fn(),
  none: jest.fn()
};

const pgp = () => () => mockDb;

pgp.__mockDb = mockDb;

module.exports = pgp;
