import { describe, it, expect, beforeEach, vi } from 'vitest';

// Mock the Clarity contract interactions
const mockTimepieces = new Map();
let mockLastTimepieceId = 0;

// Mock contract functions
const mockContract = {
  registerTimepiece: (manufacturer, model, serialNumber, year) => {
    const newId = mockLastTimepieceId + 1;
    mockTimepieces.set(newId, {
      owner: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM', // Mock principal
      manufacturer,
      model,
      serialNumber,
      year,
      registeredAt: Date.now()
    });
    mockLastTimepieceId = newId;
    return { value: newId };
  },
  
  getTimepiece: (id) => {
    return mockTimepieces.get(id) || null;
  },
  
  transferTimepiece: (id, newOwner) => {
    if (!mockTimepieces.has(id)) {
      return { error: 404 };
    }
    
    const timepiece = mockTimepieces.get(id);
    timepiece.owner = newOwner;
    mockTimepieces.set(id, timepiece);
    return { value: true };
  }
};

describe('Timepiece Registry Contract', () => {
  beforeEach(() => {
    mockTimepieces.clear();
    mockLastTimepieceId = 0;
  });
  
  it('should register a new timepiece', () => {
    const result = mockContract.registerTimepiece('Rolex', 'Submariner', 'SN12345', 1985);
    expect(result.value).toBe(1);
    
    const timepiece = mockContract.getTimepiece(1);
    expect(timepiece).not.toBeNull();
    expect(timepiece.manufacturer).toBe('Rolex');
    expect(timepiece.model).toBe('Submariner');
    expect(timepiece.serialNumber).toBe('SN12345');
    expect(timepiece.year).toBe(1985);
  });
  
  it('should retrieve a timepiece by ID', () => {
    mockContract.registerTimepiece('Omega', 'Speedmaster', 'OM54321', 1969);
    
    const timepiece = mockContract.getTimepiece(1);
    expect(timepiece).not.toBeNull();
    expect(timepiece.manufacturer).toBe('Omega');
    expect(timepiece.model).toBe('Speedmaster');
  });
  
  it('should transfer ownership of a timepiece', () => {
    mockContract.registerTimepiece('Patek Philippe', 'Nautilus', 'PP98765', 1976);
    
    const newOwner = 'ST2REHHS5J3CERCRBEPMGH7KQ2VZKGWSXN0MKZZZU';
    const result = mockContract.transferTimepiece(1, newOwner);
    expect(result.value).toBe(true);
    
    const timepiece = mockContract.getTimepiece(1);
    expect(timepiece.owner).toBe(newOwner);
  });
});
