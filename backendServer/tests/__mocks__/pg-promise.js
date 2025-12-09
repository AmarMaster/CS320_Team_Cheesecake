// tests/__mocks__/pg-promise.js

const mockDb = {
  many: jest.fn(),
  manyOrNone: jest.fn(),
  one: jest.fn(),
  none: jest.fn()
};

mockDb.none = jest.fn((...args) => {
  console.log('MOCK DB .none CALLED WITH:', args);
  return Promise.resolve();
});

const pgp = () => () => mockDb;

pgp.__mockDb = mockDb;

module.exports = pgp;
