pragma solidity ^0.4.23;
pragma experimental ABIEncoderV2;

contract DGame {
  enum Winner {
    NONE,
    PLAYER_0,
    PLAYER_1
  }

  enum NextPlayers {
    NONE,
    PLAYER_0,
    PLAYER_1,
    BOTH
  }

  uint32 internal constant REASON_NONE = 0;
  uint32 private constant REASON_OUT_OF_TURN = 0x80000000;
  uint32 private constant REASON_NOT_A_HASH = 0x80000001;
  uint32 private constant REASON_WRONG_HASH = 0x80000002;
  uint32 private constant REASON_WRONG_LENGTH = 0x80000003;

  enum MetaTag {
    NONE,
    COMMITTING_RANDOM,
    REVEALING_RANDOM,
    COMMITTING_SECRET,
    REVEALING_SECRET
  }

  struct MetaState {
    uint32 nonce;
    MetaTag tag;
    bytes data;
    State state;
  }

  struct State {
    uint32 tag;
    bytes data;
  }

  struct Move {
    uint8 playerID;
    bytes data;
  }

  constructor(address anOwner) public {
    owner = anOwner;
  }

  function matchDuration() public pure returns (uint) {
    assert(false);
  }

  function isSecretSeedValid(address /* account */, bytes secretSeed) public view returns (bool) {
    return secretSeed.length == 0;
  }

  function secretSeedRating(bytes /* secretSeed */) public pure returns (uint32) {
    return 0;
  }

  function publicSeed(bytes /* secretSeed */) public pure returns (bytes) {
    return new bytes(0);
  }

  function initialState(bytes /* publicSeed0 */, bytes /* publicSeed1 */) public pure returns (MetaState) {
    return meta(State(0, new bytes(0)));
  }

  function winner(MetaState metaState) public pure returns (Winner) {
    if (metaState.tag == MetaTag.NONE) {
      return winnerImplementation(metaState.state);

    } else if (metaState.tag == MetaTag.COMMITTING_RANDOM) {
      return Winner.NONE;

    } else if (metaState.tag == MetaTag.REVEALING_RANDOM) {
      return Winner.NONE;

    } else if (metaState.tag == MetaTag.COMMITTING_SECRET) {
      return Winner.NONE;

    } else if (metaState.tag == MetaTag.REVEALING_SECRET) {
      return Winner.NONE;
    }
  }

  function nextPlayers(MetaState metaState) public pure returns (NextPlayers) {
    if (winner(metaState) != Winner.NONE) {
      return NextPlayers.NONE;
    }

    if (metaState.tag == MetaTag.NONE) {
      return nextPlayersImplementation(metaState.state);

    } else if (metaState.tag == MetaTag.COMMITTING_RANDOM) {
      return NextPlayers.BOTH;

    } else if (metaState.tag == MetaTag.REVEALING_RANDOM) {
      return NextPlayers.BOTH;

    } else if (metaState.tag == MetaTag.COMMITTING_SECRET) {
      return NextPlayers.BOTH;

    } else if (metaState.tag == MetaTag.REVEALING_SECRET) {
      return NextPlayers.BOTH;
    }
  }

  function isMoveLegal(MetaState metaState, Move move) public pure returns (bool, uint32) {
    NextPlayers next;
    bytes32 hash;
    uint i;

    next = nextPlayers(metaState);

    if (next == NextPlayers.NONE) {
      return (false, REASON_OUT_OF_TURN);

    } else if (next == NextPlayers.PLAYER_0) {
      if (move.playerID != 0) {
        return (false, REASON_OUT_OF_TURN);
      }

    } else if (next == NextPlayers.PLAYER_1) {
      if (move.playerID != 1) {
        return (false, REASON_OUT_OF_TURN);
      }
    }

    if (metaState.tag == MetaTag.NONE) {
      return isMoveLegalImplementation(metaState.state, move);

    } else if (metaState.tag == MetaTag.COMMITTING_RANDOM) {
      if (move.data.length == 32) {
        return (true, REASON_NONE);

      } else {
        return (false, REASON_NOT_A_HASH);
      }

    } else if (metaState.tag == MetaTag.REVEALING_RANDOM) {
      if (move.data.length != uint(metaState.data[0])) {
        return (false, REASON_WRONG_LENGTH);
      }

      hash = keccak256(move.data);

      for (i = 0; i < 32; i++) {
        if (hash[i] != metaState.data[1 + 32 * move.playerID + i]) {
          return (false, REASON_WRONG_HASH);
        }
      }

      return (true, REASON_NONE);

    } else if (metaState.tag == MetaTag.COMMITTING_SECRET) {
      if (move.data.length == 32) {
        return (true, REASON_NONE);

      } else {
        return (false, REASON_NOT_A_HASH);
      }

    } else if (metaState.tag == MetaTag.REVEALING_SECRET) {
      hash = keccak256(move.data);

      for (i = 0; i < 32; i++) {
        if (hash[i] != metaState.data[32 * move.playerID + i]) {
          return (false, REASON_WRONG_HASH);
        }
      }

      return (true, REASON_NONE);
    }
  }

  function nextState(MetaState metaState, Move move) public pure returns (MetaState) {
    MetaState memory next;

    if (metaState.tag == MetaTag.NONE) {
      next = nextStateImplementation(metaState.state, move);

    } else if (metaState.tag == MetaTag.COMMITTING_RANDOM) {
      assert(false);

    } else if (metaState.tag == MetaTag.REVEALING_RANDOM) {
      assert(false);

    } else if (metaState.tag == MetaTag.COMMITTING_SECRET) {
      assert(false);

    } else if (metaState.tag == MetaTag.REVEALING_SECRET) {
      assert(false);
    }

    next.nonce = metaState.nonce + 1;

    return next;
  }

  function nextState(MetaState metaState, Move aMove, Move anotherMove) public pure returns (MetaState) {
    Move[2] memory moves;
    MetaState memory next;
    bytes memory data;
    uint i;

    require(aMove.playerID != anotherMove.playerID);

    moves[aMove.playerID] = aMove;
    moves[anotherMove.playerID] = anotherMove;

    if (metaState.tag == MetaTag.NONE) {
      next = nextStateImplementation(metaState.state, moves[0], moves[1]);

    } else if (metaState.tag == MetaTag.COMMITTING_RANDOM) {
      for (i = 0; i < 32; i++) {
        if (moves[0].data[i] != moves[1].data[i]) {
          break;
        }
      }

      if (i == 32) {
        next = metaState;

      } else {
        next.tag = MetaTag.REVEALING_RANDOM;
        next.data = new bytes(65);
        next.data[0] = metaState.data[0];

        for (i = 0; i < 32; i++) {
          next.data[1 + i] = moves[0].data[i];
          next.data[33 + i] = moves[1].data[i];
        }

        next.state = metaState.state;
      }

    } else if (metaState.tag == MetaTag.REVEALING_RANDOM) {
      data = new bytes(uint(metaState.data[0]));

      for (i = 0; i < data.length; i++) {
        data[i] = moves[0].data[i] ^ moves[1].data[i];
      }

      next = onRandomize(metaState.state, data);

    } else if (metaState.tag == MetaTag.COMMITTING_SECRET) {
      for (i = 0; i < 32; i++) {
        if (moves[0].data[i] != moves[1].data[i]) {
          break;
        }
      }

      if (i == 32) {
        next = metaState;

      } else {
        next.tag = MetaTag.REVEALING_SECRET;
        next.data = new bytes(64);

        for (i = 0; i < 32; i++) {
          next.data[i] = moves[0].data[i];
          next.data[32 + i] = moves[1].data[i];
        }

        next.state = metaState.state;
      }

    } else if (metaState.tag == MetaTag.REVEALING_SECRET) {
      next = onReveal(metaState.state, moves[0].data, moves[1].data);
    }

    next.nonce = metaState.nonce + 1;

    return next;
  }

  modifier restricted { require(msg.sender == owner); _; }

  function registerWin(address winnerAccount, uint32 winnerSeedRating, uint32 loserSeedRating, State state, uint8 winnerID) public restricted {
    registerWinImplementation(winnerAccount, winnerSeedRating, loserSeedRating, state, winnerID);
  }

  function registerCheat(address cheaterAccount) public restricted {
    registerCheatImplementation(cheaterAccount);
  }

  function registerWinImplementation(address /* winnerAccount */, uint32 /* winnerSeedRating */, uint32 /* loserSeedRating */, State /* state */, uint8 /* winnerID */) internal {
  }

  function registerCheatImplementation(address /* cheaterAccount */) internal {
  }

  function winnerImplementation(State state) internal pure returns (Winner);
  function nextPlayersImplementation(State state) internal pure returns (NextPlayers);
  function isMoveLegalImplementation(State state, Move move) internal pure returns (bool, uint32);

  function nextStateImplementation(State /* state */, Move /* move */) internal pure returns (MetaState) {
    assert(false);
  }

  function nextStateImplementation(State /* state */, Move /* aMove */, Move /* anotherMove */) internal pure returns (MetaState) {
    assert(false);
  }

  function onRandomize(State /* state */, bytes /* data */) internal pure returns (MetaState) {
    assert(false);
  }

  function onReveal(State /* state */, bytes /* secret0 */, bytes /* secret1 */) internal pure returns (MetaState) {
    assert(false);
  }

  function meta(State state) internal pure returns (MetaState) {
    MetaState memory metaState;

    metaState.tag = MetaTag.NONE;
    metaState.state = state;

    return metaState;
  }

  function randomize(State state, uint8 nBytes) internal pure returns (MetaState) {
    MetaState memory metaState;

    require(nBytes >= 8);

    metaState.tag = MetaTag.COMMITTING_RANDOM;
    metaState.data = new bytes(1);
    metaState.data[0] = byte(nBytes);
    metaState.state = state;

    return metaState;
  }

  function commit(State state) internal pure returns (MetaState) {
    MetaState memory metaState;

    metaState.tag = MetaTag.COMMITTING_SECRET;
    metaState.state = state;

    return metaState;
  }

  address private owner;
}
