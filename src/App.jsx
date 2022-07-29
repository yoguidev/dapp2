import { EthProvider } from "./contexts/EthContext";
import Demo from "./components/Demo";
import Footer from "./components/Footer";
import "./App.css";



function Button() {
  return<button>Hello</button>
}

function App() {
  return (
    <EthProvider>
      <div id="App" >
        <div className="container">

          <Demo />
          <Button/>
          <hr />
          <Footer />
        </div>
      </div>
    </EthProvider>
  );
}

export default App;
