import { useState } from 'react'
import Logo from './assets/logo.png'
import './css/style.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <>
      <div>
        <img src={Logo} className="logo" alt="Beamer logo" />
      </div>
      <h1>Beamer Standard Business Template</h1>
      <div className="card">
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
        <p>
          Edit <code>src/App.jsx</code> and save to test HMR
        </p>
      </div>
      <p className="read-the-docs">
        More about this is comming later
      </p>
    </>
  )
}

export default App
