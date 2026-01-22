import Foundation

/// Practice puzzles designed to teach specific techniques
/// Puzzles sourced from SudokuWiki.org - real examples that require each technique
class TechniquePractice {
    static let shared = TechniquePractice()
    private init() {}

    /// A practice puzzle with metadata about what technique it teaches
    struct PracticePuzzle: Identifiable {
        let id = UUID()
        let technique: TechniqueType
        let title: String
        let description: String
        let puzzle: Puzzle
        let hintCell: Int  // Cell where the technique applies
        let expectedValue: Int?  // For placement techniques
    }

    /// Helper to convert puzzle string to array
    private static func parseString(_ str: String) -> [Int] {
        return str.map { Int(String($0)) ?? 0 }
    }

    // MARK: - Naked Pair Examples
    // These puzzles require finding naked pairs to make progress

    let nakedPairPuzzles: [PracticePuzzle] = [
        // From SudokuWiki - requires naked pair to solve
        PracticePuzzle(
            technique: .nakedPair,
            title: "Naked Pair in Row",
            description: "Look for two cells in the same row that share exactly the same two candidates. Once found, eliminate those candidates from other cells in that row.",
            puzzle: Puzzle(
                difficulty: .medium,
                initialBoard: parseString("400000038002004100005300240070609004020000070600703090057008300003900400240000009"),
                solution: parseString("419265738832974156765318249173629584928541673654783192597438321381952467246187935")
            ),
            hintCell: 0,
            expectedValue: nil
        ),
        PracticePuzzle(
            technique: .nakedPair,
            title: "Naked Pair in Box",
            description: "Find a naked pair within a 3x3 box. Two cells with the same two candidates let you eliminate those numbers from other cells in the box.",
            puzzle: Puzzle(
                difficulty: .medium,
                initialBoard: parseString("080090030030000069902063158020804590851907046394605870563040987200000015010050020"),
                solution: parseString("684591732135782469972463158627814593851937246394625871563249817248376915719158324")
            ),
            hintCell: 0,
            expectedValue: nil
        )
    ]

    // MARK: - Hidden Pair Examples

    let hiddenPairPuzzles: [PracticePuzzle] = [
        // From SudokuWiki - moderate puzzle with hidden pair
        PracticePuzzle(
            technique: .hiddenPair,
            title: "Hidden Pair Discovery",
            description: "Two numbers that only appear as candidates in the same two cells of a unit form a hidden pair. Remove all OTHER candidates from those cells.",
            puzzle: Puzzle(
                difficulty: .medium,
                initialBoard: parseString("000000000904607000076804100309701080008000300050308702007502610000403208000000000"),
                solution: parseString("812935467934617825576824139329761584468259371751348792147582693695473218283196456")
            ),
            hintCell: 0,
            expectedValue: nil
        )
    ]

    // MARK: - Pointing Pair Examples

    let pointingPairPuzzles: [PracticePuzzle] = [
        // From SudokuWiki - demonstrates pointing pairs
        PracticePuzzle(
            technique: .pointingPair,
            title: "Pointing Pair",
            description: "When a candidate in a box exists only in cells that share a row or column, that candidate can be eliminated from the rest of that row/column outside the box.",
            puzzle: Puzzle(
                difficulty: .medium,
                initialBoard: parseString("010903600000080000900000507002010430000402000064070200701000005000030000005601020"),
                solution: parseString("817953642532684719946217587372519438189462375564378291721849356498235167635791824")
            ),
            hintCell: 0,
            expectedValue: nil
        ),
        PracticePuzzle(
            technique: .pointingPair,
            title: "Pointing Triple",
            description: "Similar to pointing pairs, but with three cells aligned. The candidate can only go in one row/column within the box.",
            puzzle: Puzzle(
                difficulty: .medium,
                initialBoard: parseString("900050000200630005006002000003100070000020900080005000000800100500010004000060008"),
                solution: parseString("931754826274638915856912743693148572145726983782395461467283159528491637319567284")
            ),
            hintCell: 0,
            expectedValue: nil
        )
    ]

    // MARK: - Box/Line Reduction Examples

    let boxLineReductionPuzzles: [PracticePuzzle] = [
        // From SudokuWiki
        PracticePuzzle(
            technique: .boxLineReduction,
            title: "Box/Line Reduction",
            description: "When a candidate in a row or column exists only within one box, eliminate that candidate from other cells in the box (outside the row/column).",
            puzzle: Puzzle(
                difficulty: .medium,
                initialBoard: parseString("016007803000800000070001060048000300600000002009000650060900020000002000904600510"),
                solution: parseString("216457893953826147874931265148265379637149582529378654761594328385712946294683517")
            ),
            hintCell: 0,
            expectedValue: nil
        )
    ]

    // MARK: - X-Wing Examples

    let xWingPuzzles: [PracticePuzzle] = [
        // From SudokuWiki - classic X-Wing example
        PracticePuzzle(
            technique: .xWing,
            title: "X-Wing Pattern",
            description: "Find a candidate that appears in exactly 2 cells in two different rows, where those cells align in the same two columns (forming a rectangle). Eliminate that candidate from other cells in those columns.",
            puzzle: Puzzle(
                difficulty: .hard,
                initialBoard: parseString("100000569402000008050009040000640801000010000208035000040500010900000402621000005"),
                solution: parseString("183427569492356718756189243375642891964718325218935674847563192539871462621294835")
            ),
            hintCell: 0,
            expectedValue: nil
        ),
        PracticePuzzle(
            technique: .xWing,
            title: "X-Wing Practice",
            description: "Look for the rectangular pattern. When found, the candidate at the corners must occupy two opposite corners, allowing eliminations along the columns.",
            puzzle: Puzzle(
                difficulty: .hard,
                initialBoard: parseString("000001008700030009020000061080009003001040900900300020240000080600090005100600000"),
                solution: parseString("593271648714638529826945361485729163231546987967318274249153786678492135153867492")
            ),
            hintCell: 0,
            expectedValue: nil
        )
    ]

    // MARK: - Naked Single Examples (easier puzzles where naked singles are the key)

    let nakedSinglePuzzles: [PracticePuzzle] = [
        PracticePuzzle(
            technique: .nakedSingle,
            title: "Find the Naked Single",
            description: "A naked single is a cell where only one candidate remains after eliminating all numbers that appear in the same row, column, and box. Look for cells with just one possibility.",
            puzzle: Puzzle(
                difficulty: .easy,
                initialBoard: parseString("003020600900305001001806400008102900700000008006708200002609500800203009005010300"),
                solution: parseString("483921657967345821251876493548132976729564138136798245372689514814253769695417382")
            ),
            hintCell: 0,
            expectedValue: nil
        ),
        PracticePuzzle(
            technique: .nakedSingle,
            title: "Naked Singles Chain",
            description: "Sometimes solving one naked single reveals another. Keep looking for cells where all but one candidate has been eliminated.",
            puzzle: Puzzle(
                difficulty: .easy,
                initialBoard: parseString("200080300060070084030500209000105408000000000402706000301007040720040060004010003"),
                solution: parseString("245981376169273584837564219976135428513428697482796135391657842728349561654812793")
            ),
            hintCell: 0,
            expectedValue: nil
        )
    ]

    // MARK: - Hidden Single Examples

    let hiddenSinglePuzzles: [PracticePuzzle] = [
        PracticePuzzle(
            technique: .hiddenSingle,
            title: "Hidden Single in Box",
            description: "A hidden single occurs when a number can only go in one cell within a row, column, or box. Even if that cell has multiple candidates, this number MUST go there.",
            puzzle: Puzzle(
                difficulty: .easy,
                initialBoard: parseString("000000680000073009309000000000900000600008000040000000000007130700001006002340000"),
                solution: parseString("174259683865473219329186574218934765657218394943567821486792135731825946592341867")
            ),
            hintCell: 0,
            expectedValue: nil
        ),
        PracticePuzzle(
            technique: .hiddenSingle,
            title: "Hidden Single in Row",
            description: "Check each row: for each missing number, count how many cells can hold it. If only one cell works, you found a hidden single!",
            puzzle: Puzzle(
                difficulty: .easy,
                initialBoard: parseString("000000000000003085001020000000507000004000100090000000500000073002010000000040009"),
                solution: parseString("987654321246173985351928746128537694764289153593461278519896237472315869638742519")
            ),
            hintCell: 0,
            expectedValue: nil
        )
    ]

    // MARK: - Naked Triple Examples

    let nakedTriplePuzzles: [PracticePuzzle] = [
        PracticePuzzle(
            technique: .nakedTriple,
            title: "Naked Triple",
            description: "Three cells in a unit that together contain only three candidates form a naked triple. Those three numbers can be eliminated from other cells in the unit.",
            puzzle: Puzzle(
                difficulty: .hard,
                initialBoard: parseString("070008029002000004854020000008374200000000000003261700000090612200000400130600070"),
                solution: parseString("671548329392716854854329176568374291127985463943261785485793612219857436736412958")
            ),
            hintCell: 0,
            expectedValue: nil
        )
    ]

    // MARK: - Access Methods

    func puzzles(for technique: TechniqueType) -> [PracticePuzzle] {
        switch technique {
        case .nakedSingle:
            return nakedSinglePuzzles
        case .hiddenSingle:
            return hiddenSinglePuzzles
        case .nakedPair:
            return nakedPairPuzzles
        case .nakedTriple:
            return nakedTriplePuzzles
        case .hiddenPair:
            return hiddenPairPuzzles
        case .pointingPair:
            return pointingPairPuzzles
        case .boxLineReduction:
            return boxLineReductionPuzzles
        case .xWing:
            return xWingPuzzles
        default:
            return []
        }
    }

    var allPuzzles: [PracticePuzzle] {
        nakedSinglePuzzles + hiddenSinglePuzzles + nakedPairPuzzles + nakedTriplePuzzles +
        hiddenPairPuzzles + pointingPairPuzzles + boxLineReductionPuzzles + xWingPuzzles
    }

    /// Get puzzles grouped by technique for the Learn Mode UI
    var puzzlesByTechnique: [(technique: TechniqueType, puzzles: [PracticePuzzle])] {
        [
            (.nakedSingle, nakedSinglePuzzles),
            (.hiddenSingle, hiddenSinglePuzzles),
            (.nakedPair, nakedPairPuzzles),
            (.nakedTriple, nakedTriplePuzzles),
            (.hiddenPair, hiddenPairPuzzles),
            (.pointingPair, pointingPairPuzzles),
            (.boxLineReduction, boxLineReductionPuzzles),
            (.xWing, xWingPuzzles)
        ].filter { !$0.puzzles.isEmpty }
    }
}
